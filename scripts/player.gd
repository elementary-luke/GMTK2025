extends CharacterBody2D

var move = Vector2(0.0, 0.0)
var speed = 200.0
var segments = []
var player_correction = Vector2(0, 0)
var casting_rope = false
var moving = false
var no_move = false
var move_step = Vector2(0.0, 0.0)
var stunned = false
var stun_invincibility_dur = 0.5
var can_be_stunned = true
var last = Vector2(0, 0)
var can_extend = false
var rope_left = 150.0
var max_rope = 150.0
var min_rope_segments = 2

var anim_name = "idle_forward"
var last_dir = "forward"

func _ready():
	Global.Player = self

func update(delta: float) -> void:
	Global.time_lived += delta
	Global.player_position = global_position
	
	var intent = Vector2.ZERO
	
	intent.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	intent.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	if stunned:
		intent = Vector2.ZERO
	
	if no_move:
		intent = Vector2.ZERO
	
	moving = intent != Vector2.ZERO

	var walk_player = $WalkSoundPlayer
	
	if moving:
		var angle = intent.angle()
		if not walk_player.playing:
			walk_player.play()
	else:
		if walk_player.playing:
			walk_player.stop()
	
	play_anim(intent)
	
	var move_dir = intent.normalized()
	move_step = move_dir * speed
		
	if casting_rope:
		var to_end = global_position.distance_to(segments[-2].pos)
		if to_end >= Global.Rope.seg_len and can_extend and rope_left > 0:#&& Global.Rope.get_rope_length() >= Global.Rope.max_length():
			Global.Rope.add_segment()
			rope_left -= 1
			rope_left = max(rope_left, 0)
			
		if Input.is_action_just_pressed("main_action"):
			can_extend = !can_extend
		
	else:
		Global.Rope.start_pos = global_position
		if Input.is_action_just_pressed("main_action") and rope_left > min_rope_segments:
			for i in range(0, min_rope_segments):
				Global.Rope.add_segment()
				rope_left -= min_rope_segments
				rope_left = max(rope_left, 0)
			casting_rope = true
			can_extend = true
	
	velocity = move_step
	
	move_and_slide() 
	
	no_move = false
	

func play_anim(intent):
	if !stunned:
		if moving:
			if abs(intent.x) > abs(intent.y):
				if intent.x > 0:
					anim_name = "run_side"
					$AnimatedSprite2D.flip_h = false
					last_dir = "right"
				if intent.x < 0:
					anim_name = "run_side"
					$AnimatedSprite2D.flip_h = true
					last_dir = "left"
			else:
				if intent.y > 0:
					anim_name = "run_forward"
					$AnimatedSprite2D.flip_h = false
					last_dir = "forward"
				if intent.y < 0:
					anim_name = "run_back"
					$AnimatedSprite2D.flip_h = true
					last_dir = "back"
		else:
			if last_dir == "forward":
				anim_name = "idle_forward"
				$AnimatedSprite2D.flip_h = false
			if last_dir == "right":
				anim_name = "idle_side"
				$AnimatedSprite2D.flip_h = false
			if last_dir == "left":
				anim_name = "idle_side"
				$AnimatedSprite2D.flip_h = true
			if last_dir == "back":
				anim_name = "idle_back"
				$AnimatedSprite2D.flip_h = true
			
		$AnimatedSprite2D.play(anim_name)

func stun(time):
	if can_be_stunned:
		can_be_stunned = false
		stunned = true
		$ShakeTimer.start()
		$AudioStreamPlayer2D.play()
		$AnimatedSprite2D.play("frozen")
		await get_tree().create_timer(time).timeout
		$ShakeTimer.stop()
		stunned = false
		await get_tree().create_timer(stun_invincibility_dur).timeout
		can_be_stunned = true
		
func _on_shake_timer_timeout() -> void:
	var random_vector = Vector2(randf_range(0,2), randf_range(0,2))
	position += random_vector
	await get_tree().create_timer(0.02).timeout
	position -= random_vector

func add_rope(amount):
	rope_left += amount
	rope_left = min(rope_left, max_rope)
