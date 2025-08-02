extends CharacterBody2D

var starting_position : Vector2
var dir : float
var stun_time = 0.4

const BULLET_SPEED = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = global_position
	dir = (Global.player_position - starting_position).angle()

func _process(delta: float) -> void:
	position += Vector2(BULLET_SPEED * cos(dir), BULLET_SPEED * sin(dir))
	
func _physics_process(delta: float) -> void:
	var d = Vector2(cos(dir), sin(dir))
	look_at(d)
	var coll = move_and_collide(Vector2(cos(dir), sin(dir)) * BULLET_SPEED)
	if coll:
		queue_free()
		var body = coll.get_collider()
		if body == Global.Player:
			body.stun(stun_time)
