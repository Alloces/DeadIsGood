extends CharacterBody2D
class_name Dude

signal died(killer_name: String)

enum Types {
	Red,
	Green,
	Yellow,
	Purple,
}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

const GROUP = "dude"

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _camera: Camera2D = $Camera2D
@onready var _teleport_camera: Camera2D = $TeleportCamera
@onready var _teleport_collsion_checks := {
	Vector2(-128, 0): $YellowActionArea/Left,
	Vector2(128, 0): $YellowActionArea/Right,
	Vector2(0, -128): $YellowActionArea/Up,
	Vector2(0, 128): $YellowActionArea/Down,
}
@onready var _yellow_area: Node2D = $YellowActionArea
@onready var _purple_area: Area2D = $PurpleActionArea
@onready var _red_area: Area2D = $RedActionArea
@onready var _area: Area2D = $Area2D
@onready var _block_for_red: Node2D = $BlockForRed

@export var is_player: bool = false :
	get:
		return is_player
	set(val):
		is_player = val
		if _camera == null:
			return
		
		_change_is_player_state()

@export var type: Types = Types.Red :
	get:
		return type
	set(new_type):
		type = new_type
		if _sprite == null:
			return
		
		# TODO: check if type in dict
		_sprite.set_region_rect(TypeRects[type])
		_purple_area.set_visible(new_type == Types.Purple)
		_red_area.set_visible(new_type == Types.Red)
		_yellow_area.set_visible(new_type == Types.Yellow)

@export var tilemap: TileMap
@export var block_atlas_coords: Vector2i = Vector2i(4, 7)
const empty_atlas_coords: Vector2i = Vector2i(-1, -1)

var _previous_masked_block = {
	"is_set": false,
	"position": empty_atlas_coords,
	"atlas_coords": empty_atlas_coords,
}

var TypeRects: Dictionary = {
	Types.Red: 		Rect2(576, 320, 64, 64),
	Types.Green: 	Rect2(576, 448, 64, 64),
	Types.Yellow: 	Rect2(576, 256, 64, 64),
	Types.Purple: 	Rect2(576, 384, 64, 64),
}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _current_direction: float

var _created_tiles: Array[Vector2i] = []

func _ready() -> void:
	_change_is_player_state()
	_sprite.set_region_rect(TypeRects[type])
	_purple_area.set_visible(type == Types.Purple)
	_red_area.set_visible(type == Types.Red)
	_yellow_area.set_visible(type == Types.Yellow)


func _change_is_player_state() -> void:
	_area.call_deferred("set_monitoring", is_player)
	_area.call_deferred("set_monitorable", !is_player)
	
	if is_player:
		_camera.make_current()
		_area.connect("area_entered", _on_area_2d_area_entered)
	elif _area.is_connected("area_entered", _on_area_2d_area_entered):
		_area.disconnect("area_entered", _on_area_2d_area_entered)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_player:
		_parse_input()
	else:
		_parse_npc_behavior()
	
	move_and_slide()
	
	if type == Types.Purple:
		_purple_tile_mask()


func _parse_input() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		use_ability()
	
	move(Input.get_axis("ui_left", "ui_right"))


func _parse_npc_behavior() -> void:
	pass


func move(direction: float) -> void:
	if direction:
		velocity.x = direction * SPEED
		
		_sprite.flip_h = direction < 0
		_red_area.position.x = -55 if direction < 0 else 55
		_purple_area.position.x = _red_area.position.x
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func use_ability() -> void:
	match type:
		Types.Red:
			_red_ability()
		Types.Green:
			_green_ability()
		Types.Yellow:
			_yellow_ability()
		Types.Purple:
			_purple_ability()


func _red_ability() -> void:
	var cell: Vector2i = tilemap.local_to_map(position)
	cell.x += -1 if _sprite.is_flipped_h() else 1
	
	var atlas_coords: Vector2i = tilemap.get_cell_atlas_coords(0, cell)
	if _block_for_red.visible:
		if atlas_coords != empty_atlas_coords || _red_area.has_overlapping_areas():
			return
		
		tilemap.set_cell(0, cell, 0, block_atlas_coords)
		_block_for_red.set_visible(false)
	else:
		if atlas_coords != block_atlas_coords:
			return
		
		tilemap.set_cell(0, cell, 0, empty_atlas_coords)
		_block_for_red.set_visible(true)


func _green_ability() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func _appear_chibis():
	visible = true
	_camera.make_current()
	set_physics_process(true)
	set_process_input(true)

func teleport(place: Vector2) -> void:
	var area_to_move := _teleport_collsion_checks[place] as Area2D
	if area_to_move.has_overlapping_bodies():
		return

	_teleport_camera.position = position
	_teleport_camera.make_current()

	set_physics_process(false)
	set_process_input(false)
	visible = false
	position += place

	var tween := create_tween()
	tween.tween_property(_teleport_camera, "position", position, 0.2)
	tween.finished.connect(_appear_chibis)

func _yellow_ability() -> void:
	if is_on_floor():
		if Input.is_action_pressed("ui_left"):
			teleport(Vector2(-128, 0))
		elif Input.is_action_pressed("ui_right"):
			teleport(Vector2(128, 0))
		elif Input.is_action_pressed("ui_up"):
			teleport(Vector2(0, -128))
		elif Input.is_action_pressed("ui_down"):
			teleport(Vector2(0, 128))
		else:
			return


func _purple_ability() -> void:
	var cell: Vector2i = tilemap.local_to_map(_purple_area.global_position)
	var atlas_coords: Vector2i = tilemap.get_cell_atlas_coords(0, cell)
	if (tilemap.get_cell_alternative_tile(0, cell) == 1 and atlas_coords == block_atlas_coords) or atlas_coords == empty_atlas_coords:
		if _purple_area.has_overlapping_areas():
			return
		
		tilemap.set_cell(0, cell, 0, block_atlas_coords)
		_previous_masked_block.is_set = false
		_created_tiles.append(cell)
		if _created_tiles.size() > 3:
			tilemap.set_cell(0, _created_tiles.pop_front(), 0, empty_atlas_coords)
		
	elif atlas_coords == block_atlas_coords:
		tilemap.set_cell(0, cell, 0, empty_atlas_coords)
		_previous_masked_block.is_set = false
		_created_tiles.erase(cell)


func _purple_tile_mask() -> void:
	var cell: Vector2i = tilemap.local_to_map(_purple_area.global_position)
	var atlas_coords: Vector2i = tilemap.get_cell_atlas_coords(0, cell)
	if tilemap.get_cell_alternative_tile(0, cell) != 0 and atlas_coords != empty_atlas_coords:
		return
	
	if atlas_coords == empty_atlas_coords:
		tilemap.set_cell(0, cell, 0, block_atlas_coords, 1)
	elif atlas_coords == block_atlas_coords:
		tilemap.set_cell(0, cell, 0, block_atlas_coords, 3)
	
	if _previous_masked_block.is_set:
		tilemap.set_cell(0, _previous_masked_block.position, 0, _previous_masked_block.atlas_coords)
	
	_previous_masked_block.is_set = true
	_previous_masked_block.position = cell
	_previous_masked_block.atlas_coords = atlas_coords


func _on_area_2d_area_entered(area: Area2D):
	emit_signal("died", area.get_parent().name)
