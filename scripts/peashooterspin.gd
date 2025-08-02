extends CharacterBody2D

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
	Global.Player.add_rope(rope_value)
	queue_free()


func _on_timer_timeout() -> void:
	if (Global.player_position - global_position).length() < 300.0:
		var dir = randf_range(0.0, 2*PI)
		for i in range(0, 10):
			await get_tree().create_timer(0.03).timeout
			var bullet = load("res://scenes/enemies/spin_bullet.tscn").instantiate()
			bullet.global_position = global_position
			bullet.dir = dir
			get_tree().current_scene.add_child(bullet)
			dir += randf_range(0.4, 1.0)
		$Timer.start()
