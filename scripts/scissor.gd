extends CharacterBody2D

var target = null
var seg_index = null
var attached = false
var speed = 0.2
var cut = 0.0
var cut_time = 4.0

func _physics_process(delta: float) -> void:
	var segments = Global.Rope.segments
	if Global.Player.casting_rope:
		if seg_index != null:
			if attached:
				if seg_index + 1< segments.size():
					look_at(segments[seg_index + 1].pos)
					rotation += deg_to_rad(90.0)
					global_position = segments[seg_index].pos
					cut += delta
					if cut > cut_time:
						Global.Rope.cut(seg_index)
					else:
						$Sprite2D.modulate.g = 1.0 - cut / cut_time
						$Sprite2D.modulate.b = 1.0 - cut / cut_time
			else:
				if seg_index < segments.size():
					look_at(segments[seg_index].pos)
					var diff = segments[seg_index].pos - global_position
					if diff.length() < 5.0 && segments[seg_index].scissor == null:
						attached = true
						segments[seg_index].scissor = self
					else:
						global_position += diff.normalized() * speed
	else:
		reset()

func reset():
	target = null
	seg_index = null
	attached = false
	cut = 0.0
	$LookTimer.start(0.2)
	$Sprite2D.modulate.g = 1.0
	$Sprite2D.modulate.b = 1.0

func _on_look_timer_timeout() -> void:
	if !attached:
		seg_index = Global.Rope.get_nearest_point(global_position)
