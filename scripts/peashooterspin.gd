extends CharacterBody2D

var bullet_scn = preload("res://scenes/projectiles/spin_bullet.tscn")
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var previous_frame = -1

var rope_value = 10.0


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if $AnimatedSprite2D.animation != "spin":
		if global_position.x > Global.player_position.x:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	
	if global_position.distance_to(Global.player_position) > Global.despawn_distance:
		queue_free()
		
func die():
	if !Global.Root.game_ended:
		Global.Player.add_rope(rope_value)
		Global.Root.gain_label(rope_value, global_position)
	queue_free()


func _on_timer_timeout() -> void:
	if (Global.player_position - global_position).length() < 300.0:
		var dir = 0.0
		$AnimatedSprite2D.play("spin")
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.pause()
		var d = 1.0
		if $AnimatedSprite2D.flip_h:
			d = -1.0
			dir = PI
		
		for i in range(0, 8):
			var bullet = bullet_scn.instantiate()
			bullet.global_position = $ShootPos.global_position
			bullet.dir = dir
			get_tree().current_scene.add_child(bullet)
			
			dir += 0.25 * PI * d
			
			await get_tree().create_timer(0.08).timeout #0.08
			$AnimatedSprite2D.frame += 1
		
		$AnimatedSprite2D.play("default")
	$Timer.start()
