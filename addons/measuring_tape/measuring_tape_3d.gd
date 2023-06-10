@tool
@icon("icons/measuring_tape_3d.svg")
class_name MeasuringTape3D
extends Marker3D

@export var measure = Units.MeasureType.LENGTH: set = set_measure
@export var unit = Units.UnitType.METER: set = set_unit
@export var decimal_count := 2: set = set_decimal_count

var _editor_camera: Camera3D
var _editor_viewport: SubViewport
var _geometry: ImmediateMesh
var _label: Label
var _sprite: Sprite3D
@onready var _parent = get_parent()


func _ready():
	
	# TODO: This is a really janky way to get the editor viewport. Waiting for https://github.com/godotengine/godot-proposals/issues/1302
	var editor_cameras: Array[Camera3D]
	editor_cameras = get_editor_cameras()
	##################################################################
	
	if not Engine.is_editor_hint():
		queue_free()
		return
	if not _parent is Node3D:
		print("i am here 4")
		printerr("Failed to create MeasuringTape3D. The parent of a MeasuringTape3D must be Node3D-derived.")
		queue_free()
		return
	
	_editor_viewport = editor_cameras[0].get_parent()
	_editor_camera = _editor_viewport.get_child(0)
	print(_editor_viewport)
	print(_editor_camera)
	# Set up the line.
	_geometry = ImmediateMesh.new()
	_parent.call_deferred("add_child", _geometry)
	# Set up the Label.
	_label = Label.new()
	_label.custom_minimum_size = Vector2(400, 30)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_editor_viewport.add_child(_label)


# TODO: This is a really janky way to get the editor viewport. Waiting for https://github.com/godotengine/godot-proposals/issues/1302
func get_editor_cameras() -> Array[Camera3D]:
	var ei: EditorInterface = EditorScript.new().get_editor_interface()
	var cameras: Array[Camera3D]
	find_editor_cameras(ei.get_editor_main_screen().get_children(), cameras)
	return cameras
##################################################################

# TODO: This is a really janky way to get the editor viewport. Waiting for https://github.com/godotengine/godot-proposals/issues/1302	
func find_editor_cameras(nodes: Array, cameras: Array) -> void:	
	for child in nodes:
		find_editor_cameras(child.get_children(), cameras)
		if child is Camera3D:
			cameras.push_back(child)
##################################################################


func _process(_delta):
	
	if not _geometry or not _label:
		print("i am here 2")
		return
	_geometry.clear()
	_geometry.begin(Mesh.PRIMITIVE_LINES)
	_geometry.add_vertex(Vector3.ZERO)
	var end: Vector3
	var abs_position: Vector3 = position.abs()
	var amount: float
	if measure == Units.MeasureType.LENGTH:
		_geometry.add_vertex(position)
		amount = position.length()
	if measure == Units.MeasureType.AREA or measure == Units.MeasureType.PERIMETER:
		var min_axis = abs_position.min_axis_index()
		# These vertices generate a square.
		if min_axis == Vector3.AXIS_X:
			_geometry.add_vertex(Vector3(0, position.y, 0))
			_geometry.add_vertex(Vector3(0, position.y, 0))
			_geometry.add_vertex(Vector3(0, position.y, position.z))
			_geometry.add_vertex(Vector3(0, position.y, position.z))
			_geometry.add_vertex(Vector3(0, 0, position.z))
			_geometry.add_vertex(Vector3(0, 0, position.z))
			_geometry.add_vertex(Vector3(0, 0, 0))
			end = Vector3(0, position.y, position.z)
			if measure == Units.MeasureType.AREA:
				amount = abs_position.y * abs_position.z
			else: # measure == Units.MeasureType.PERIMETER:
				amount = (abs_position.y + abs_position.z) * 2
		elif min_axis == Vector3.AXIS_Y:
			_geometry.add_vertex(Vector3(position.x, 0, 0))
			_geometry.add_vertex(Vector3(position.x, 0, 0))
			_geometry.add_vertex(Vector3(position.x, 0, position.z))
			_geometry.add_vertex(Vector3(position.x, 0, position.z))
			_geometry.add_vertex(Vector3(0, 0, position.z))
			_geometry.add_vertex(Vector3(0, 0, position.z))
			_geometry.add_vertex(Vector3(0, 0, 0))
			end = Vector3(position.x, 0, position.z)
			if measure == Units.MeasureType.AREA:
				amount = abs_position.x * abs_position.z
			else: # measure == Units.MeasureType.PERIMETER:
				amount = (abs_position.x + abs_position.z) * 2
		else: # min_axis == Vector3.AXIS_Z:
			_geometry.add_vertex(Vector3(position.x, 0, 0))
			_geometry.add_vertex(Vector3(position.x, 0, 0))
			_geometry.add_vertex(Vector3(position.x, position.y, 0))
			_geometry.add_vertex(Vector3(position.x, position.y, 0))
			_geometry.add_vertex(Vector3(0, position.y, 0))
			_geometry.add_vertex(Vector3(0, position.y, 0))
			_geometry.add_vertex(Vector3(0, 0, 0))
			end = Vector3(position.x, position.y, 0)
			if measure == Units.MeasureType.AREA:
				amount = abs_position.x * abs_position.y
			else: # measure == Units.MeasureType.PERIMETER:
				amount = (abs_position.x + abs_position.y) * 2
	else:
		end = position
	if measure == Units.MeasureType.VOLUME or measure == Units.MeasureType.SURFACE_AREA:
		# These vertices generate a cube.
		_geometry.add_vertex(Vector3(position.x, 0, 0))
		_geometry.add_vertex(Vector3(position.x, 0, 0))
		_geometry.add_vertex(Vector3(position.x, position.y, 0))
		_geometry.add_vertex(Vector3(position.x, position.y, 0))
		_geometry.add_vertex(position)
		_geometry.add_vertex(position)
		_geometry.add_vertex(Vector3(0, position.y, position.z))
		_geometry.add_vertex(Vector3(0, position.y, position.z))
		_geometry.add_vertex(Vector3(0, 0, position.z))
		_geometry.add_vertex(Vector3(0, 0, position.z))
		_geometry.add_vertex(Vector3(position.x, 0, position.z))
		_geometry.add_vertex(Vector3(position.x, 0, position.z))
		_geometry.add_vertex(position)
		_geometry.add_vertex(Vector3(0, 0, 0))
		_geometry.add_vertex(Vector3(0, 0, position.z))
		_geometry.add_vertex(Vector3(0, position.y, position.z))
		_geometry.add_vertex(Vector3(0, position.y, 0))
		_geometry.add_vertex(Vector3(0, position.y, 0))
		_geometry.add_vertex(Vector3(position.x, position.y, 0))
		_geometry.add_vertex(Vector3(0, 0, 0))
		_geometry.add_vertex(Vector3(0, position.y, 0))
		_geometry.add_vertex(Vector3(position.x, 0, 0))
		_geometry.add_vertex(Vector3(position.x, 0, position.z))
		if measure == Units.MeasureType.VOLUME:
			amount = abs_position.x * abs_position.y * abs_position.z
		else:
			amount = (abs_position.x * abs_position.y +
					abs_position.x * abs_position.z +
					abs_position.y * abs_position.z) * 2
	_geometry.end()
	var center = _parent.global_transform * (end / 2)
	_label.text = Units.convert_to_unit_str(amount, unit, measure, decimal_count)
	_label.visible = not _editor_camera.is_position_behind(center)
	_label.position = _editor_camera.unproject_position(center)
	_label.position -= (_label.custom_minimum_size / 2)
	print("i am here 3")


func _exit_tree():
	if _geometry:
		_geometry.queue_free()
	if _label:
		_label.queue_free()
	if _sprite:
		_sprite.queue_free()


func set_measure(value: int):
	measure = value
	if (unit == Units.UnitType.HECTARE or unit == Units.UnitType.ACRE) and \
			value != Units.MeasureType.AREA and value != Units.MeasureType.SURFACE_AREA:
		unit = Units.UnitType.METER
		notify_property_list_changed()
	elif (unit == Units.UnitType.LITER or unit == Units.UnitType.GALLON) and \
			value != Units.MeasureType.VOLUME:
		unit = Units.UnitType.METER
		notify_property_list_changed()


func set_unit(value: int):
	unit = value
	if (value == Units.UnitType.HECTARE or value == Units.UnitType.ACRE) and \
			measure != Units.MeasureType.AREA and measure != Units.MeasureType.SURFACE_AREA:
		measure = Units.MeasureType.AREA
		notify_property_list_changed()
	elif (value == Units.UnitType.LITER or value == Units.UnitType.GALLON) and \
			measure != Units.MeasureType.VOLUME:
		measure = Units.MeasureType.VOLUME
		notify_property_list_changed()


func set_decimal_count(value: int):
	value = int(clamp(value, 0, 10))
	decimal_count = value
