extends CharacterBody2D
class_name Dude

enum Types {
	Red,
	Green,
	Yellow,
	Purple,
}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _camera: Camera2D = $Camera2D

@export var is_player: bool = false :
	get:
		return is_player
	set(val):
		is_player = val
		if _camera == null:
			return
		
		_camera.set_enabled(true)

@export var type: Types = Types.Red :
	get:
		return type
	set(new_type):
		type = new_type
		if _sprite == null:
			return
		
		# TODO: check if type in dict
		_sprite.set_region_rect(TypeRects[type])

var TypeRects: Dictionary = {
	Types.Red: 		Rect2(576, 320, 64, 64),
	Types.Green: 	Rect2(576, 448, 64, 64),
	Types.Yellow: 	Rect2(576, 256, 64, 64),
	Types.Purple: 	Rect2(576, 384, 64, 64),
}

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	_camera.enabled = is_player
	_sprite.set_region_rect(TypeRects[type])


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_player:
		_parse_input()
	else:
		_parse_npc_behavior()
	
	move_and_slide()


func _parse_input() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		use_ability()
	
	move(Input.get_axis("ui_left", "ui_right"))


func _parse_npc_behavior() -> void:
	pass


func move(direction: float) -> void:
	if direction:
		velocity.x = direction * SPEED
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
	print("red ability")


func _green_ability() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _yellow_ability() -> void:
	print("yellow ability")


func _purple_ability() -> void:
	print("purple ability")
