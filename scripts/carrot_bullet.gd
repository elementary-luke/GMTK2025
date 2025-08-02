extends CharacterBody2D

var starting_position : Vector2
var dir : float
var stun_time = 0.4
var rope_dmg = 4

var bullet_speed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = global_position

func _process(delta: float) -> void:
	position += Vector2(bullet_speed * cos(dir), bullet_speed * sin(dir))
	
func _physics_process(delta: float) -> void:
	var d = Vector2(cos(dir), sin(dir))
	look_at(d)
	var coll = move_and_collide(Vector2(cos(dir), sin(dir)) * bullet_speed)
	if coll:
		queue_free()
		var body = coll.get_collider()
		if body == Global.Player:
			body.stun(stun_time, rope_dmg)
	
		if global_position.distance_to(Global.player_position) > Global.despawn_distance:
			queue_free()
