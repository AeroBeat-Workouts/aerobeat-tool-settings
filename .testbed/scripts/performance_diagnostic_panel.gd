extends Control

const HIGH_FPS_DELTA := 1.0 / 60.0
const LOW_FPS_DELTA := 1.0 / 24.0
const DEBUG_SAMPLE_COUNT := 96

@onready var profile_selector: OptionButton = %ProfileSelector
@onready var sampling_status_label: Label = %SamplingStatusLabel
@onready var recommendation_text: TextEdit = %RecommendationText
@onready var signals_text: TextEdit = %SignalsText
@onready var reasons_text: TextEdit = %ReasonsText
@onready var events_text: TextEdit = %EventsText

var _manager: AeroToolManager
var _event_history: Array[String] = []

func _ready() -> void:
	_ensure_manager()
	_connect_manager_events()
	_populate_profile_selector()
	_manager.sample_static_signals()
	_manager.begin_live_sampling({"active_environment_profile": _selected_profile()})
	_refresh_view()

func _ensure_manager() -> void:
	if has_node("AeroToolManager"):
		_manager = $AeroToolManager
		return
	_manager = AeroToolManager.new()
	_manager.name = "AeroToolManager"
	add_child(_manager)

func _connect_manager_events() -> void:
	if not _manager.recommendation_updated.is_connected(_on_recommendation_updated):
		_manager.recommendation_updated.connect(_on_recommendation_updated)
	if not _manager.downgrade_recommended.is_connected(_on_downgrade_recommended):
		_manager.downgrade_recommended.connect(_on_downgrade_recommended)

func _populate_profile_selector() -> void:
	if profile_selector.item_count > 0:
		return
	for tier in ["high", "medium", "low"]:
		profile_selector.add_item(tier.capitalize())
		profile_selector.set_item_metadata(profile_selector.item_count - 1, tier)
	profile_selector.select(0)

func _selected_profile() -> String:
	var index := profile_selector.get_selected_id()
	var metadata = profile_selector.get_item_metadata(index)
	if metadata == null:
		return "high"
	return String(metadata)

func _refresh_view() -> void:
	if _manager == null:
		return
	var recommendation := _manager.get_current_recommendation()
	var signals := _manager.get_current_signals()
	var reasons := _manager.get_current_reasons()
	sampling_status_label.text = "Sampling active: %s | Active env: %s | Downgrade recommended: %s" % [
		str(signals.get("sampling_active", false)),
		_selected_profile(),
		str(_manager.should_downgrade_for_active_environment())
	]
	recommendation_text.text = JSON.stringify(recommendation, "  ")
	signals_text.text = JSON.stringify(signals, "  ")
	reasons_text.text = "\n".join(PackedStringArray(reasons))
	events_text.text = "\n\n".join(_event_history)

func _append_event(title: String, payload: Dictionary) -> void:
	_event_history.push_front("%s\n%s" % [title, JSON.stringify(payload, "  ")])
	while _event_history.size() > 10:
		_event_history.pop_back()
	_refresh_view()

func _inject_debug_burst(delta_seconds: float, label: String) -> void:
	if _manager == null or _manager._performance_manager == null:
		return
	_manager.begin_live_sampling({"active_environment_profile": _selected_profile()})
	for _sample_index in range(DEBUG_SAMPLE_COUNT):
		_manager._performance_manager.inject_debug_frame_sample(delta_seconds)
	_append_event("Simulated %s" % label, _manager.get_current_recommendation())

func _on_refresh_static_pressed() -> void:
	_manager.sample_static_signals()
	_refresh_view()

func _on_start_sampling_pressed() -> void:
	_manager.begin_live_sampling({"active_environment_profile": _selected_profile()})
	_refresh_view()

func _on_stop_sampling_pressed() -> void:
	_manager.stop_live_sampling()
	_refresh_view()

func _on_simulate_high_fps_pressed() -> void:
	_inject_debug_burst(HIGH_FPS_DELTA, "60 FPS burst")

func _on_simulate_low_fps_pressed() -> void:
	_inject_debug_burst(LOW_FPS_DELTA, "24 FPS burst")

func _on_poll_timer_timeout() -> void:
	_refresh_view()

func _on_recommendation_updated(result: Dictionary) -> void:
	_append_event("recommendation_updated", result)

func _on_downgrade_recommended(event: Dictionary) -> void:
	_append_event("downgrade_recommended", event)
