extends GutTest

var _manager: AeroSettingsManager

func before_each() -> void:
	_manager = AeroSettingsManager.new()
	add_child(_manager)
	_manager._initialize()

func after_each() -> void:
	if is_instance_valid(_manager):
		_manager.free()

func test_settings_manager_exposes_frozen_first_slice_surface() -> void:
	assert_eq(AeroSettingsManager.VERSION, "0.1.0", "Version should reflect the first implementation slice")
	assert_true(_manager.has_signal("recommendation_updated"), "Public facade should expose recommendation_updated")
	assert_true(_manager.has_signal("downgrade_recommended"), "Public facade should expose downgrade_recommended")
	assert_true(_manager.has_method("sample_static_signals"), "Public facade should expose sample_static_signals")
	assert_true(_manager.has_method("begin_live_sampling"), "Public facade should expose begin_live_sampling")
	assert_true(_manager.has_method("stop_live_sampling"), "Public facade should expose stop_live_sampling")
	assert_true(_manager.has_method("get_current_recommendation"), "Public facade should expose get_current_recommendation")
	assert_true(_manager.has_method("get_current_signals"), "Public facade should expose get_current_signals")
	assert_true(_manager.has_method("get_current_reasons"), "Public facade should expose get_current_reasons")
	assert_true(_manager.has_method("should_downgrade_for_active_environment"), "Public facade should expose should_downgrade_for_active_environment")

func test_static_signals_and_initial_recommendation_have_expected_shape() -> void:
	var signals := _manager.sample_static_signals()
	assert_true(signals.has("platform"), "Static signals should include platform")
	assert_true(signals.has("renderer_name"), "Static signals should include renderer name")
	assert_true(signals.has("resolution"), "Static signals should include resolution")
	assert_true(signals.has("resolution_bucket"), "Static signals should include a resolution bucket")

	var recommendation := _manager.get_current_recommendation()
	assert_true(recommendation.has("tier"), "Recommendation should include tier")
	assert_true(recommendation.has("confidence"), "Recommendation should include confidence")
	assert_true(recommendation.has("recommended_environment_profile"), "Recommendation should include recommended_environment_profile")
	assert_true(recommendation.has("startup_estimate"), "Recommendation should include startup_estimate")
	assert_true(recommendation.has("live_confirmed"), "Recommendation should include live_confirmed")
	assert_true(recommendation.has("signals"), "Recommendation should include signals")
	assert_true(recommendation.has("reasons"), "Recommendation should include reasons")
	assert_false(bool(recommendation.get("live_confirmed", true)), "Recommendation should not be live-confirmed before sampling")

func test_live_sampling_uses_post_load_truth_and_recommends_downgrade_after_sustained_low_fps() -> void:
	var recommendation_events: Array[Dictionary] = []
	var downgrade_events: Array[Dictionary] = []
	_manager.recommendation_updated.connect(func(result: Dictionary): recommendation_events.append(result))
	_manager.downgrade_recommended.connect(func(event: Dictionary): downgrade_events.append(event))

	_manager.begin_live_sampling({"active_environment_profile": "high"})
	for _sample_index in range(72):
		_manager._performance_manager.inject_debug_frame_sample(1.0 / 24.0)

	var recommendation := _manager.get_current_recommendation()
	assert_eq(String(recommendation.get("tier", "")), "low", "Low live FPS should override the startup estimate")
	assert_true(bool(recommendation.get("live_confirmed", false)), "Recommendation should become live-confirmed after enough samples")
	assert_eq(String(recommendation.get("recommended_environment_profile", "")), "low", "Recommended environment profile should follow the live tier")
	assert_true(_manager.should_downgrade_for_active_environment(), "Sustained low FPS should recommend a downgrade for a high active environment")
	assert_true(recommendation_events.size() > 0, "Sampling should emit recommendation updates")
	assert_eq(downgrade_events.size(), 1, "Downgrade recommendation should emit once for the same active tier")
	assert_eq(String(downgrade_events[0].get("reason", "")), "sustained_low_fps", "Downgrade event should use the frozen reason code")
	assert_eq(float(downgrade_events[0].get("threshold_duration_ms", 0.0)), 3000.0, "Downgrade event should expose the frozen duration threshold")

func test_high_fps_live_sampling_keeps_high_recommendation_without_downgrade() -> void:
	_manager.begin_live_sampling({"active_environment_profile": "high"})
	for _sample_index in range(120):
		_manager._performance_manager.inject_debug_frame_sample(1.0 / 60.0)

	var recommendation := _manager.get_current_recommendation()
	assert_eq(String(recommendation.get("tier", "")), "high", "High live FPS should keep the high recommendation")
	assert_false(_manager.should_downgrade_for_active_environment(), "High FPS should not recommend a downgrade")
