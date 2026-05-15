## Public runtime entrypoint for the AeroBeat tool-settings package.
##
## This facade keeps the frozen first-slice contract centered on AeroToolManager
## while delegating implementation details to the performance recommendation
## manager underneath.
class_name AeroToolManager
extends Node

#region SIGNALS
signal initialized
signal recommendation_updated(result: Dictionary)
signal downgrade_recommended(event: Dictionary)
#endregion

#region ENUMS & CONSTANTS
const VERSION: String = "0.1.0"
const PerformanceManagerScript := preload("res://src/AeroPerformanceRecommendationManager.gd")
#endregion

#region EXPORTS
@export var is_active: bool = true
#endregion

#region PRIVATE VARIABLES
var _is_initialized: bool = false
var _performance_manager: AeroPerformanceRecommendationManager
#endregion

#region LIFECYCLE
func _ready() -> void:
	_initialize()

func _initialize() -> void:
	if _is_initialized:
		return

	_performance_manager = PerformanceManagerScript.new()
	add_child(_performance_manager)
	_performance_manager.recommendation_updated.connect(func(result: Dictionary): recommendation_updated.emit(result))
	_performance_manager.downgrade_recommended.connect(func(event: Dictionary): downgrade_recommended.emit(event))
	_is_initialized = true
	initialized.emit()
#endregion

#region PUBLIC API
func sample_static_signals() -> Dictionary:
	_initialize()
	return _performance_manager.sample_static_signals()

func begin_live_sampling(context: Dictionary = {}) -> void:
	_initialize()
	_performance_manager.begin_live_sampling(context)

func stop_live_sampling() -> void:
	if not _is_initialized:
		return
	_performance_manager.stop_live_sampling()

func get_current_recommendation() -> Dictionary:
	_initialize()
	return _performance_manager.get_current_recommendation()

func get_current_signals() -> Dictionary:
	_initialize()
	return _performance_manager.get_current_signals()

func get_current_reasons() -> PackedStringArray:
	_initialize()
	return _performance_manager.get_current_reasons()

func should_downgrade_for_active_environment() -> bool:
	_initialize()
	return _performance_manager.should_downgrade_for_active_environment()
#endregion
