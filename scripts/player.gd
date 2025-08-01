extends CharacterBody2D

var move = Vector2(0.0, 0.0)
var speed = 160.0
var segments = []
var player_correction = Vector2(0, 0)
var casting_rope = false
var moving = false

var last_dir : String = "forward"

var anim_name := ""

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
	
	var move_dir = intent.normalized()
	var move_step = move_dir * speed
	
	if casting_rope:
		var to_end = global_position.distance_to(segments[-2].pos)
		
		if Input.is_action_pressed("main_action") && to_end >= Global.Rope.seg_len * 0.8:
			Global.Rope.add_segment()
	else:
		
		Global.Rope.start_pos = global_position
		if Input.is_action_just_pressed("main_action"):
			for i in range(0, 5):
				Global.Rope.add_segment()
			casting_rope = true
	
	velocity = move_step
	move_and_slide() 
