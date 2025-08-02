extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var previous_frame = -1

var rope_value = 10.0

var dead = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var current_frame = $AnimatedSprite2D.frame

	if current_frame == 4 and previous_frame != 4:
		if (Global.player_position - global_position).length() < 300.0:
			var bullet = load("res://scenes/enemies/enemy_bullet.tscn").instantiate()
			bullet.global_position = global_position
			get_tree().current_scene.add_child(bullet)
			
	if global_position.x > Global.player_position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	previous_frame = current_frame

func die():
	dead = true
	Global.Player.add_rope(rope_value)
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(0.6).timeout
	visible = false
	queue_free()
