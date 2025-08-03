extends CharacterBody2D

var target = null
var seg_index = null
var attached = false
var speed = 40.0
var cut = 0.0
var cut_time = 4.0
var chew_dir = 1
var idling = false
var idle_dir = Vector2(0, 0)
var rope_value = 1.0
var dead = false

func _ready():
	var type = randi_range(0, 2)
	if type == 0:
		$Sprite2D.sprite_frames = preload("res://spriteframe/default_scissor_sprite_frames.tres")
	if type == 1:
		$Sprite2D.sprite_frames = preload("res://spriteframe/blue_scissor_sprite_frames.tres")
	elif type == 2:
		$Sprite2D.sprite_frames = preload("res://spriteframe/brown_scissor_sprite_frames.tres")
	
	if randi_range(0, 1) == 0:
		chew_dir = -1
	
	reset()
	rotation = 0
	$Sprite2D.play("spawn")
	
func _physics_process(delta: float) -> void:
	if dead || $Sprite2D.animation == "spawn":
		return
	
	speed = 40.0 * (1.0 + Global.Root.difficulty) / 2.0
	var segments = Global.Rope.segments
	if Global.Player.casting_rope:
		if seg_index != null:
			if attached:
				$ProgressBar.visible = true
				if seg_index + 1< segments.size():
					look_at(segments[seg_index + 1].pos)
					if chew_dir == 1:
						rotation += deg_to_rad(180.0)
					global_position = segments[seg_index].pos
					cut += delta * (1.0 + Global.Root.difficulty) / 4.0
					if cut > cut_time:
						Global.Rope.cut(seg_index)
						$Cut.play()
						reset()
					else:
						var progress = cut / cut_time
						var frame = clamp(round(progress * 10), 0, 10)
						$ProgressBar.global_rotation = 0.0
						$ProgressBar.global_position = $CollisionShape2D.global_position + Vector2(0, -20.0)
						$ProgressBar.frame = frame
			else:
				$ProgressBar.visible = false
				if seg_index < segments.size():
					look_at(segments[seg_index].pos)
					var diff = segments[seg_index].pos - global_position
					if diff.length() < 3.0 && segments[seg_index].scissor == null:
						attached = true
						segments[seg_index].scissor = self
					else:
						velocity = diff.normalized() * speed * 0.6
						look_at(position + velocity)
						rotation -= deg_to_rad(90)
						move_and_slide()
	else:
		if !idling:
			look_smwhr_new()
			idling = true
			$ProgressBar.visible = false
			$IdleTimer.start(randf_range(1.0, 3.0))
		elif idle_dir != Vector2.ZERO:
			velocity = idle_dir * speed
			look_at(position + velocity)
			rotation -= deg_to_rad(90)
			move_and_slide()
			
	if global_position.distance_to(Global.player_position) > Global.despawn_distance:
		queue_free()

func _on_idle_timer_timeout() -> void:
	if idling:
		idle_dir = Vector2(0, 0)
	else:
		return
		
	await get_tree().create_timer(randf_range(0.5, 2.0)).timeout
	if idling:
		look_smwhr_new()
		$IdleTimer.start(randf_range(1.0, 5.0))

func look_smwhr_new():
	idle_dir = Vector2(1.0, 0.0).rotated(randf_range(0, 2 * PI))

func reset():
	target = null
	seg_index = null
	attached = false
	cut = 0.0
	$LookTimer.start(0.2)
	$ProgressBar.hide()

func _on_look_timer_timeout() -> void:
	if !attached:
		var si = Global.Rope.get_nearest_point(global_position)
		if si != -1:
			seg_index = si

func die():
	reset()
	dead = true
	if !Global.Root.game_ended:
		Global.Player.add_rope(rope_value)
		
	rotation = 0
	$Sprite2D.play("death")
	
	await get_tree().create_timer(0.4).timeout
	
	if !Global.Root.game_ended:
		Global.Root.gain_label(rope_value, global_position)
	queue_free()


func _on_sprite_2d_animation_finished() -> void:
	if $Sprite2D.animation == "spawn":
		$Sprite2D.play("default")
