extends CharacterBody2D

var move = Vector2(0.0, 0.0)
var speed = 200.0
var segments = []
var player_correction = Vector2(0, 0)
var casting_rope = false
var moving = false
var no_move = false

func _ready():
	Global.Player = self

func update(delta: float) -> void:
	Global.player_position = global_position
	
	var intent = Vector2.ZERO
	intent.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	intent.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	moving = intent != Vector2.ZERO
	
	if moving:
		var angle = intent.angle()
		var anim_name := ""
		
		if abs(intent.x) > abs(intent.y):
			if intent.x > 0:
				anim_name = "run_side"
				$AnimatedSprite2D.flip_h = false
			if intent.x < 0:
				anim_name = "run_side"
				$AnimatedSprite2D.flip_h = true
		else:
			if intent.y > 0:
				anim_name = "run_forward"
				$AnimatedSprite2D.flip_h = false
			if intent.y < 0:
				anim_name = "run_back"
				$AnimatedSprite2D.flip_h = true
		
		$AnimatedSprite2D.play(anim_name)
	else:
		$AnimatedSprite2D.stop()
	
	var move_dir = intent.normalized()
	var move_step = move_dir * speed
	
	if casting_rope:
		var to_end = global_position.distance_to(segments[-2].pos)
		if Input.is_action_pressed("main_action") && to_end >= Global.Rope.seg_len:#&& Global.Rope.get_rope_length() >= Global.Rope.max_length():
			Global.Rope.add_segment()
	else:
		
		Global.Rope.start_pos = global_position
		if Input.is_action_just_pressed("main_action"):
			for i in range(0, 5):
				Global.Rope.add_segment()
			casting_rope = true
	
	if !no_move:
		velocity = move_step
		move_and_slide() 
	
	no_move = false
