extends Node2D

var t = 0.0
var mag = 0.15
var f = 1.0
var scale_mag = 0.05 # Max scale change from original

func _process(delta: float) -> void:
	t += delta

	# Rotation
	$Sprite2D.rotation = mag * sin(2 * f * t)

	# Vertical bobbing
	$Sprite2D.position.y += mag/2 * cos(f / 1.5 * t)

	# Scaling (pulsing)
	var scale_factor = 1.0 + scale_mag * sin(f * t)
	$Sprite2D.scale = Vector2.ONE * (scale_factor / 10)


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
