extends Node2D
class_name Dude

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum Types {
	Red,
	Green,
	Yellow,
	Purple,
}

var TypeRects: Dictionary = {
	Types.Red: 		Rect2(576, 320, 64, 64),
	Types.Green: 	Rect2(576, 448, 64, 64),
	Types.Yellow: 	Rect2(576, 256, 64, 64),
	Types.Purple: 	Rect2(576, 384, 64, 64),
}

@export var _character: CharacterBody2D
@onready var _sprite: Sprite2D = $Sprite2D

@onready var type: Types = Types.Red :
	get:
		return type
	set(new_type):
		# TODO: check if type in dict
		type = new_type
		_sprite.set_region_rect(TypeRects[type])

func _ready() -> void:
	if _character == null:
		print("Dude -> ready: character must not be null")
		return


func move(direction: float) -> void:
	if direction:
		_character.velocity.x = direction * SPEED
	else:
		_character.velocity.x = move_toward(_character.velocity.x, 0, SPEED)


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
	if _character.is_on_floor():
		_character.velocity.y = JUMP_VELOCITY


func _yellow_ability() -> void:
	print("yellow ability")


func _purple_ability() -> void:
	print("purple ability")
