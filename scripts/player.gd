extends CharacterBody2D

var move = Vector2(0.0, 0.0)
var speed = 2.0
var segments = []
var player_correction = Vector2(0, 0)
var last = Vector2(0, 0)
var casting_rope = false
var moving = false

func _ready():
	Global.Player = self

func update(delta: float) -> void:
	Global.player_position = global_position
	
	var intent = Vector2.ZERO
	intent.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	intent.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	moving = intent != Vector2.ZERO
	
	var move_dir = intent.normalized()
	var move_step = move_dir * speed
		
	if casting_rope:
		var to_end = global_position.distance_to(segments[-2].pos)
		
		if Input.is_action_pressed("main_action") && to_end >= Global.Rope.seg_len * 0.8:
			Global.Rope.add_segment()
			last = global_position
	else:
		
		Global.Rope.start_pos = global_position
		if Input.is_action_just_pressed("main_action"):
			for i in range(0, 5):
				Global.Rope.add_segment()
			casting_rope = true
	
	position += move_step
