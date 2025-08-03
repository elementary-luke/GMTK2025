extends Node2D

var mag = 0.15
var f = 1.0
var scale_mag = 0.05
var screen = 0

func _ready() -> void:
	$Cover.get_node("AnimationPlayer").play("FadeIn")

func _physics_process(delta: float) -> void:
	$Panels.position.x = lerp($Panels.position.x, -512.0 * float(screen), 0.2)
	
	if screen == 0:
		$left.modulate.a = lerp($left.modulate.a, 0.0, 0.2)
	else:
		$left.modulate.a = lerp($left.modulate.a, 1.0, 0.2)
	
	if screen == 2:
		$right.modulate.a = lerp($right.modulate.a, 0.0, 0.2)
	else:
		$right.modulate.a = lerp($right.modulate.a, 1.0, 0.2)

func _on_texture_button_pressed() -> void:
	$Button.play()
	$Cover.get_node("AnimationPlayer").play("FadeOut")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_left_pressed() -> void:
	if screen != 0:
		$Button.play()
		screen -= 1
	
	
func _on_right_pressed() -> void:
	if screen != 2:
		$Button.play()
		screen += 1
