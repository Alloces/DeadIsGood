extends Node2D


@export var _player: Dude

@onready var _tilemap: TileMap = $TileMap

func _ready() -> void:
	if _player == null:
		push_error("Level -> ready: player must not be empty")
	
	_player.connect("died", _change_player)
	
	for dude in get_tree().get_nodes_in_group(Dude.GROUP) as Array[Dude]: 
		dude.tilemap = _tilemap


func _change_player(killer_name: String) -> void:
	_player.disconnect("died", _change_player)
	_player.is_player = false
	_player.queue_free()
	call_deferred("remove_child", _player)
	
	_player = get_node(killer_name)
	_player.is_player = true
	_player.connect("died", _change_player)
