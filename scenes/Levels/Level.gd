extends Node2D


@export var _player: Node


func _ready() -> void:
	if _player == null:
		push_error("Level -> ready: player must not be empty")
	
	

func _change_player(killer_name: String) -> void:
	_player.queue_free()
	_player = get_node(killer_name)
	_player.is_player = true
