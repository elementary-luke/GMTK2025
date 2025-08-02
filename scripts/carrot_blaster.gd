extends CharacterBody2D

const SPEED = 50.0
var bullet_scn = preload("res://scenes/projectiles/carrot_bullet.tscn")
var rope_value = 10.0
var dir: Vector2
var last_dir: String
var attacking = false
var true_dir: Vector2
var has_fired_bullet = false

var dead = false

func _ready() -> void:
	$DirectionTimer.start()
	update_random_direction()

func _physics_process(delta: float) -> void:
	if attacking:
		return
	
	dir = true_dir
	if !dead:
		play_anim()
	velocity = SPEED * dir
	move_and_slide()

func play_anim():
	if abs(dir.x) > abs(dir.y):
		$AnimatedSprite2D.play("run_side")
		if dir.x > 0:
			$AnimatedSprite2D.flip_h = true
			last_dir = "right"
		else:
			$AnimatedSprite2D.flip_h = false
			last_dir = "left"
	else:
		if dir.y > 0:
			$AnimatedSprite2D.play("run_forward")
			$AnimatedSprite2D.flip_h = false
			last_dir = "forward"
		else:
			$AnimatedSprite2D.play("run_back")
			$AnimatedSprite2D.flip_h = true
			last_dir = "back"

func die():
	dead = true
	if Global.Player.rope_left > 0:
		Global.Player.add_rope(rope_value)
		
	$AnimatedSprite2D.play("death")
	await get_tree().create_timer(0.6).timeout
	visible = false
	queue_free()

func _on_attack_timer_timeout() -> void:
	attacking = true
	has_fired_bullet = false

func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.frame == 5 and attacking and not has_fired_bullet:
		has_fired_bullet = true
		
		await get_tree().create_timer(0.1).timeout

		if last_dir == "left":
			$AnimatedSprite2D.play("attack_side")
			$AnimatedSprite2D.flip_h = false
		elif last_dir == "right":
			$AnimatedSprite2D.play("attack_side")
			$AnimatedSprite2D.flip_h = true
		elif last_dir == "forward":
			$AnimatedSprite2D.play("attack_front")
			$AnimatedSprite2D.flip_h = false
		elif last_dir == "back":
			$AnimatedSprite2D.play("attack_back")
			$AnimatedSprite2D.flip_h = true

		await get_tree().create_timer(0.45).timeout

		var bullet = bullet_scn.instantiate()
		bullet.dir = (Global.player_position - global_position).angle()
		bullet.global_position = global_position
		get_tree().current_scene.add_child(bullet)

		attacking = false

func _on_direction_timer_timeout() -> void:
	update_random_direction()

func update_random_direction():
	var offset = Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) * 100.0
	true_dir = (Global.player_position + offset - global_position).normalized()
