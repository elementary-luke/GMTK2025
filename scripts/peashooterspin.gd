extends CharacterBody2D

var bullet_scn = preload("res://scenes/projectiles/spin_bullet.tscn")
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var previous_frame = -1

var rope_value = 10.0


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
			
	if global_position.x > Global.player_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
func die():
	if Global.Player.rope_left > 0:
		Global.Player.add_rope(rope_value)
	queue_free()


func _on_timer_timeout() -> void:
	if (Global.player_position - global_position).length() < 300.0:
		var dir = 0.0
		$AnimatedSprite2D.play("spin")
		$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.pause()
		$AnimatedSprite2D.scale.x = -1.0
		for i in range(0, 8):
			await get_tree().create_timer(0.08).timeout
			var bullet = bullet_scn.instantiate()
			bullet.global_position = global_position
			bullet.dir = dir
			get_tree().current_scene.add_child(bullet)
			$AnimatedSprite2D.frame += 1
			dir += 0.25 * PI
		$AnimatedSprite2D.scale.x = 1.0
		$AnimatedSprite2D.play("default")
		$Timer.start()
