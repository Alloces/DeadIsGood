extends CharacterBody2D

@export var type: Dude.Types = Dude.Types.Red

@onready var _dude: Dude = $Dude

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	_dude.type = type


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	_parse_input()
	move_and_slide()


func _parse_input() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_dude.use_ability()
	
	_dude.move(Input.get_axis("ui_left", "ui_right"))
