extends Area2D

var starting_position : Vector2
var dir : float

const BULLET_SPEED = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = global_position
	dir = (Global.player_position - starting_position).angle()

func _process(delta: float) -> void:
	position += Vector2(BULLET_SPEED * cos(dir), BULLET_SPEED * sin(dir))
	
