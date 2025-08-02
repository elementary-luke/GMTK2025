extends CharacterBody2D

var dir = Vector2(1.0, 0.0)
var speed = 5.0 # change in blaster
var stun_time = 1.0
var rope_dmg = 10

func _physics_process(delta: float) -> void:
	look_at(dir)
	var coll = move_and_collide(dir * speed)
	if coll:
		queue_free()
		var body = coll.get_collider()
		if body == Global.Player:
			body.stun(stun_time, rope_dmg)
	
	if global_position.distance_to(Global.player_position) > Global.despawn_distance:
		queue_free()

func die():
	$AnimationPlayer.play("FadeOut")
