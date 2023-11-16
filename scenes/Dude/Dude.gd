extends Node2D

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

@onready var sprite: Sprite2D = $Sprite2D

@onready var type: Types = Types.Red :
	get:
		return type
	set(new_type):
		# TODO: check if type in dict
		type = new_type
		sprite.set_region_rect(TypeRects[type])
