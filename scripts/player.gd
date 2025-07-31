extends CharacterBody2D

var move = Vector2(0.0, 0.0)
var speed = 2.0
var segments = []
var player_correction = Vector2(0, 0)
var last = Vector2(0, 0)

func _ready():
	Global.Player = self

func _physics_process(delta: float) -> void:
	segments = Global.Root.segments
	var anchor_pos = segments[0].pos
	var intent = Vector2.ZERO
	intent.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	intent.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	var move_dir = intent.normalized()
	var move_step = move_dir * speed

	var new_pos = global_position + move_step
	var dist_to_anchor = (new_pos - anchor_pos).length()
	
	if dist_to_anchor < Global.Root.max_length():
		position += move_step
	else:
		var rope_vec = global_position - anchor_pos
		var tangent = Vector2(-rope_vec.y, rope_vec.x).normalized()

		var arc_strength = move_dir.dot(tangent)
		var arc_move = tangent * arc_strength * speed

		position += arc_move
	
	var to_end = global_position.distance_to(segments[-1].pos)
	if Input.is_action_pressed("main_action") && to_end >= Global.Root.seg_len * 0.8:
		Global.Root.add_segment()
		last = global_position
	
	Global.Root.update(delta)
