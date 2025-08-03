extends Node2D

var mag = 0.15
var f = 1.0
var scale_mag = 0.05

func _ready() -> void:
	$Cover.get_node("AnimationPlayer").play("FadeIn")

func _process(delta: float) -> void:
	pass

func _on_texture_button_pressed() -> void:
	$Cover.get_node("AnimationPlayer").play("FadeOut")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
