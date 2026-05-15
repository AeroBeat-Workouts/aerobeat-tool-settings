class_name AeroPerformanceRecommendationManager
extends Node

signal recommendation_updated(result: Dictionary)
signal downgrade_recommended(event: Dictionary)

const LOW_FPS_THRESHOLD: float = 30.0
const DOWNGRADE_DURATION_MS: float = 3000.0
const LIVE_CONFIRMATION_MS: float = 1500.0
const STATUS_EMIT_INTERVAL_MS: float = 500.0
const TIER_RANKS := {
	"low": 0,
	"medium": 1,
	"high": 2,
}

var _static_signals: Dictionary = {}
var _current_signals: Dictionary = {}
var _current_recommendation: Dictionary = {}
var _current_reasons: PackedStringArray = []
var _sampling_context: Dictionary = {}
var _sample_window: Array[Dictionary] = []
var _sampling_active: bool = false
var _rolling_fps: float = 0.0
var _rolling_frame_time_ms: float = 0.0
var _low_fps_duration_ms: float = 0.0
var _total_sampled_ms: float = 0.0
var _time_since_emit_ms: float = 0.0
var _last_downgrade_signature: String = ""
var _last_emitted_tier: String = ""
var _last_emitted_confidence: String = ""
var _last_emitted_live_confirmed: bool = false

func _ready() -> void:
	set_process(false)
	_static_signals = sample_static_signals()
	_current_signals = _build_signal_snapshot()
	_recompute_recommendation(true)

func sample_static_signals() -> Dictionary:
	_static_signals = _capture_static_signals()
	_current_signals = _build_signal_snapshot()
	_recompute_recommendation(true)
	return _static_signals.duplicate(true)

func begin_live_sampling(context: Dictionary = {}) -> void:
	_sampling_context = context.duplicate(true)
	_sampling_active = true
	_sample_window.clear()
	_rolling_fps = 0.0
	_rolling_frame_time_ms = 0.0
	_low_fps_duration_ms = 0.0
	_total_sampled_ms = 0.0
	_time_since_emit_ms = STATUS_EMIT_INTERVAL_MS
	_last_downgrade_signature = ""
	_static_signals = sample_static_signals()
	set_process(true)
	_recompute_recommendation(true)

func stop_live_sampling() -> void:
	_sampling_active = false
	set_process(false)

func get_current_recommendation() -> Dictionary:
	return _current_recommendation.duplicate(true)

func get_current_signals() -> Dictionary:
	return _current_signals.duplicate(true)

func get_current_reasons() -> PackedStringArray:
	return _current_reasons.duplicate()

func should_downgrade_for_active_environment() -> bool:
	if _low_fps_duration_ms + 0.5 < DOWNGRADE_DURATION_MS:
		return false

	var active_tier := String(_sampling_context.get(
		"active_environment_profile",
		_current_recommendation.get("startup_estimate", "medium")
	))
	var recommended_tier := String(_current_recommendation.get("recommended_environment_profile", "medium"))
	return _tier_rank(active_tier) > _tier_rank(recommended_tier)

func inject_debug_frame_sample(delta_seconds: float) -> Dictionary:
	if delta_seconds <= 0.0:
		return get_current_recommendation()
	if not _sampling_active:
		_sampling_active = true
	_recompute_from_sample(delta_seconds, true)
	return get_current_recommendation()

func _process(delta: float) -> void:
	if not _sampling_active:
		return
	_recompute_from_sample(delta, false)

func _recompute_from_sample(delta: float, debug_sample: bool) -> void:
	var sample_ms: float = maxf(delta * 1000.0, 0.001)
	var sample: Dictionary = {
		"duration_ms": sample_ms,
		"delta_seconds": delta,
	}
	_sample_window.append(sample)
	_total_sampled_ms += sample_ms
	_time_since_emit_ms += sample_ms
	_trim_sample_window()
	_update_live_signal_state(sample_ms)

	var force_emit: bool = debug_sample
	if _time_since_emit_ms >= STATUS_EMIT_INTERVAL_MS:
		force_emit = true
		_time_since_emit_ms = 0.0

	_recompute_recommendation(force_emit)
	_maybe_emit_downgrade()

func _trim_sample_window() -> void:
	var retained_ms := 0.0
	var trimmed: Array[Dictionary] = []
	for index in range(_sample_window.size() - 1, -1, -1):
		var sample: Dictionary = _sample_window[index]
		var duration_ms := float(sample.get("duration_ms", 0.0))
		trimmed.push_front(sample)
		retained_ms += duration_ms
		if retained_ms >= DOWNGRADE_DURATION_MS:
			break
	_sample_window = trimmed

func _update_live_signal_state(sample_ms: float) -> void:
	if _sample_window.is_empty():
		_rolling_fps = 0.0
		_rolling_frame_time_ms = 0.0
		_low_fps_duration_ms = 0.0
		_current_signals = _build_signal_snapshot()
		return

	var total_duration_ms := 0.0
	for sample in _sample_window:
		total_duration_ms += float(sample.get("duration_ms", 0.0))

	if total_duration_ms <= 0.0:
		_rolling_fps = 0.0
		_rolling_frame_time_ms = 0.0
	else:
		_rolling_fps = float(_sample_window.size()) / (total_duration_ms / 1000.0)
		_rolling_frame_time_ms = total_duration_ms / float(_sample_window.size())

	if _rolling_fps < LOW_FPS_THRESHOLD:
		_low_fps_duration_ms = minf(_low_fps_duration_ms + sample_ms, total_duration_ms)
	else:
		_low_fps_duration_ms = 0.0

	_current_signals = _build_signal_snapshot()

func _recompute_recommendation(force_emit: bool) -> void:
	var startup_estimate := _estimate_startup_tier(_static_signals)
	var reasons := PackedStringArray()
	var recommended_tier := startup_estimate
	var confidence := "low"
	var live_confirmed := false

	reasons.append("Startup estimate suggests %s profile based on platform and resolution." % startup_estimate)

	if _sampling_active and _total_sampled_ms > 0.0:
		if _total_sampled_ms >= LIVE_CONFIRMATION_MS:
			live_confirmed = true
			confidence = _confidence_for_live_samples()
			recommended_tier = _recommend_tier_from_fps(_rolling_fps)
			reasons.append("Live sampling confirmed %.1f FPS rolling average after %.0f ms." % [_rolling_fps, _total_sampled_ms])
		else:
			confidence = "medium"
			reasons.append("Collecting live samples (%.0f / %.0f ms) before locking the live recommendation." % [_total_sampled_ms, LIVE_CONFIRMATION_MS])
	else:
		confidence = "low"
		reasons.append("No post-load live samples collected yet.")

	if live_confirmed:
		if recommended_tier != startup_estimate:
			reasons.append("Static estimate was %s, but live performance truth overrides it to %s." % [startup_estimate, recommended_tier])
		else:
			reasons.append("Live performance matches the startup estimate.")

	if _low_fps_duration_ms > 0.0:
		reasons.append("Low-FPS duration tracker is at %.0f ms against the %.0f ms downgrade threshold." % [_low_fps_duration_ms, DOWNGRADE_DURATION_MS])

	_current_reasons = reasons
	_current_signals = _build_signal_snapshot()
	_current_recommendation = {
		"tier": recommended_tier,
		"confidence": confidence,
		"recommended_environment_profile": recommended_tier,
		"startup_estimate": startup_estimate,
		"live_confirmed": live_confirmed,
		"signals": _current_signals.duplicate(true),
		"reasons": Array(_current_reasons),
	}

	if force_emit or _should_emit_recommendation_update():
		_last_emitted_tier = recommended_tier
		_last_emitted_confidence = confidence
		_last_emitted_live_confirmed = live_confirmed
		recommendation_updated.emit(get_current_recommendation())

func _should_emit_recommendation_update() -> bool:
	if _last_emitted_tier != String(_current_recommendation.get("tier", "")):
		return true
	if _last_emitted_confidence != String(_current_recommendation.get("confidence", "")):
		return true
	if _last_emitted_live_confirmed != bool(_current_recommendation.get("live_confirmed", false)):
		return true
	return false

func _maybe_emit_downgrade() -> void:
	if not should_downgrade_for_active_environment():
		return

	var from_tier := String(_sampling_context.get(
		"active_environment_profile",
		_current_recommendation.get("startup_estimate", "medium")
	))
	var to_tier := String(_current_recommendation.get("recommended_environment_profile", "medium"))
	var signature := "%s->%s" % [from_tier, to_tier]
	if signature == _last_downgrade_signature:
		return

	_last_downgrade_signature = signature
	downgrade_recommended.emit({
		"from_tier": from_tier,
		"to_tier": to_tier,
		"reason": "sustained_low_fps",
		"threshold_fps": LOW_FPS_THRESHOLD,
		"threshold_duration_ms": DOWNGRADE_DURATION_MS,
		"observed_average_fps": snappedf(_rolling_fps, 0.1),
		"sample_window_ms": minf(_total_sampled_ms, DOWNGRADE_DURATION_MS),
	})

func _build_signal_snapshot() -> Dictionary:
	var signals := _static_signals.duplicate(true)
	signals["rolling_fps"] = snappedf(_rolling_fps, 0.1)
	signals["rolling_frame_time_ms"] = snappedf(_rolling_frame_time_ms, 0.1)
	signals["low_fps_duration_ms"] = snappedf(_low_fps_duration_ms, 1.0)
	signals["sampling_active"] = _sampling_active
	signals["sampled_duration_ms"] = snappedf(_total_sampled_ms, 1.0)
	return signals

func _capture_static_signals() -> Dictionary:
	var viewport_size := _resolve_viewport_size()
	var platform := _map_platform_name(OS.get_name())
	var renderer_name := "unknown"
	if ProjectSettings.has_setting("rendering/renderer/rendering_method"):
		renderer_name = String(ProjectSettings.get_setting("rendering/renderer/rendering_method"))

	return {
		"platform": platform,
		"renderer_name": renderer_name,
		"resolution": [viewport_size.x, viewport_size.y],
		"resolution_bucket": _resolution_bucket_for_height(viewport_size.y),
	}

func _resolve_viewport_size() -> Vector2i:
	var size := Vector2i.ZERO
	if DisplayServer.get_name() != "headless":
		var screen_size := DisplayServer.screen_get_size()
		if screen_size.x > 0 and screen_size.y > 0:
			size = screen_size
	if size == Vector2i.ZERO and get_tree() != null and get_tree().root != null:
		var rect := get_tree().root.get_visible_rect()
		var rect_size := rect.size
		if rect_size.x > 0 and rect_size.y > 0:
			size = Vector2i(int(rect_size.x), int(rect_size.y))
	if size == Vector2i.ZERO:
		size = Vector2i(1280, 720)
	return size

func _map_platform_name(raw_name: String) -> String:
	match raw_name:
		"Linux", "FreeBSD", "NetBSD", "OpenBSD":
			return "linux"
		"Windows":
			return "windows"
		"macOS":
			return "macos"
		"Android":
			return "android"
		"iOS":
			return "ios"
		"Web":
			return "web"
		_:
			return raw_name.to_lower().replace(" ", "_")

func _resolution_bucket_for_height(height: int) -> String:
	if height >= 2160:
		return "4k"
	if height >= 1440:
		return "1440p"
	if height >= 1080:
		return "1080p"
	return "720p"

func _estimate_startup_tier(signals: Dictionary) -> String:
	var platform := String(signals.get("platform", "linux"))
	var resolution_bucket := String(signals.get("resolution_bucket", "1080p"))

	if platform == "android" or platform == "ios":
		if resolution_bucket == "4k" or resolution_bucket == "1440p":
			return "low"
		return "medium"

	match resolution_bucket:
		"4k":
			return "medium"
		"1440p":
			return "medium"
		"1080p":
			return "high"
		_:
			return "high"

func _recommend_tier_from_fps(rolling_fps: float) -> String:
	if rolling_fps >= 55.0:
		return "high"
	if rolling_fps >= 40.0:
		return "medium"
	return "low"

func _confidence_for_live_samples() -> String:
	if _total_sampled_ms >= DOWNGRADE_DURATION_MS:
		return "high"
	if _total_sampled_ms >= LIVE_CONFIRMATION_MS:
		return "medium"
	return "low"

func _tier_rank(tier: String) -> int:
	return int(TIER_RANKS.get(tier, 0))
