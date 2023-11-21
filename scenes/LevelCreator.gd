@tool
extends Node2D
class_name LevelCreator

const GRID_SIZE = [18, 10]
const TILE_SIZE = 64

enum OBJECTS {
	SPACE,
	WALL,
	BOX,
	RED,
	GREEN,
	YELLOW,
	PURPLE
}

@onready var SPRITES := {
	OBJECTS.SPACE:    get_sprite(192, 640),
	OBJECTS.WALL:     get_sprite(320, 384),
	OBJECTS.BOX:      get_sprite(256, 320),
	OBJECTS.RED:      get_sprite(576, 320),
	OBJECTS.GREEN:    get_sprite(576, 448),
	OBJECTS.YELLOW:   get_sprite(576, 256),
	OBJECTS.PURPLE:   get_sprite(576, 384),
}

var sprite_sheet = preload("res://assets/Scribble/spritesheet_default.png")

var active_instrument := OBJECTS.WALL

var Level := {}

func get_sprite(x: int, y: int):
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = sprite_sheet
	atlas_texture.region = Rect2(x, y, 64, 64)
	return atlas_texture

func set_block(x: int, y: int):
	if Input.get_mouse_button_mask() == 1:
		Level[str(x, y)] = active_instrument
		get_node(str(x, "-", y)).texture_normal = SPRITES[active_instrument]
	elif Input.get_mouse_button_mask() == 2:
		Level[str(x, y)] = OBJECTS.SPACE
		get_node(str(x, "-", y)).texture_normal = SPRITES[OBJECTS.SPACE]

func load_level():
	var res: LevelResource = ResourceLoader.load("user://level.tres")
	Level = res.data

func _ready():
	load_level()

	for x in GRID_SIZE[0]:
		for y in GRID_SIZE[1]:
			var btn := TextureButton.new()
			btn.scale = Vector2.ONE
			btn.position = Vector2(x, y) * TILE_SIZE
			btn.texture_normal = SPRITES.get(Level.get(str(x,y))) if Level.has(str(x,y)) else SPRITES[OBJECTS.SPACE]
			btn.texture_hover = SPRITES[active_instrument]
			btn.name = str(x, "-", y)

			btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
			btn.mouse_entered.connect(set_block.bind(x, y))
			btn.pressed.connect(set_block.bind(x, y))

			Level[str(x, y)] = Level.get(str(x,y)) if Level.has(str(x,y)) else OBJECTS.SPACE

			add_child(btn)

func _input(event):
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_UP) and event.pressed == true:
			var next_instrument := active_instrument - 1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else active_instrument + 1
			active_instrument = _imod(next_instrument, SPRITES.size())

			for child in get_children():
				child.texture_hover = SPRITES[active_instrument]

	if event is InputEventKey:
		if event.ctrl_pressed and event.keycode == KEY_S:
			var res = LevelResource.new()
			res.data = Level
			ResourceSaver.save(res, "user://level.tres")

func _imod(lhs: int, rhs: int) -> int:
	return lhs - floor(float(lhs) / rhs) * rhs
