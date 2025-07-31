extends CharacterBody2D

var target = null
var seg_index = null
var attached = false
var speed = 0.2

func _physics_process(delta: float) -> void:
	if Global.Player.casting_rope:
		if seg_index != null:
			if attached:
				look_at(Global.Rope.segments[seg_index + 1].pos)
				rotation += deg_to_rad(90.0)
				global_position = Global.Rope.segments[seg_index].pos
			else:
				look_at(Global.Rope.segments[seg_index].pos)
				var diff = Global.Rope.segments[seg_index].pos - global_position
				if diff.length() < speed * 3.0:
					attached = true
				else:
					global_position += diff.normalized() * speed
	else:
		target = null
		seg_index = null
		attached = false

func _on_timer_timeout() -> void:
	if !attached:
		seg_index = Global.Rope.get_nearest_point(global_position)
