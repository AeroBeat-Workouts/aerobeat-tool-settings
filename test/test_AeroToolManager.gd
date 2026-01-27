extends GutTest

var _manager: AeroToolManager

func before_each():
	_manager = AeroToolManager.new()
	add_child(_manager)

func after_each():
	_manager.free()

func test_initialization():
	assert_not_null(_manager, "Manager should be instantiated")
	assert_true(_manager.is_active, "Manager should be active by default")

func test_version():
	assert_eq(_manager.VERSION, "0.0.1", "Version should match constant")