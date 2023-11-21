extends AudioStreamPlayer2D

var music := preload("res://assets/music/music.mp3")

# Called when the node enters the scene tree for the first time.
func _ready():
	stream = music
	volume_db = -20
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
