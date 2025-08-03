extends CharacterBody2D

var bullet_scn = preload("res://scenes/projectiles/peashooter_bullet.tscn")
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var previous_frame = -1

var rope_value = 10.0

var dead = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if $AnimatedSprite2D.animation == "spawn":
		return
	
	var current_frame = $AnimatedSprite2D.frame

	if current_frame == 4 and previous_frame != 4:
		if (Global.player_position - global_position).length() < 300.0:
			var bullet = bullet_scn.instantiate()
			bullet.global_position = $ShootPos.global_position
			bullet.dir = (Global.player_position - global_position).angle()
			get_tree().current_scene.add_child(bullet)
			
	if global_position.x > Global.player_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	previous_frame = current_frame
	if global_position.distance_to(Global.player_position) > Global.despawn_distance:
		queue_free()

func die():
	dead = true
	if !Global.Root.game_ended:
		Global.Player.add_rope(rope_value)
		
		
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(0.4).timeout
	
	if !Global.Root.game_ended:
		Global.Root.gain_label(rope_value, global_position)
		
	queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "spawn":
		$AnimatedSprite2D.play("default")
