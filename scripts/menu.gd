extends Node2D

var t = 0.0
var mag = 0.15
var f = 1.0
var scale_mag = 0.05 # Max scale change from original

const SCREEN_WIDTH = 512
const SCREEN_HEIGHT = 288
const RUN_SPEED = 100.0
const PATH_AMPLITUDE = 10.0
const WAIT_TIME = 1.0

var player_direction = 1 # 1 = right, -1 = left
var player_timer = 0.0
var player_waiting = true

func _ready() -> void:
	reset_player()
	$Cover.get_node("AnimationPlayer").play("FadeIn")

func _process(delta: float) -> void:
	t += delta

	# Title logo movement
	$Title.rotation = mag * sin(2 * f * t)
	$Title.position.y += mag / 2 * cos(f / 1.5 * t)
	var scale_factor = 1.0 + scale_mag * sin(f * t)
	$Title.scale = Vector2.ONE * (scale_factor / 8)

	# Background and UI wiggle
	$ParallaxBG.rotation = mag / 5 * cos(2 * f * t)

	$CreditsText.rotation = mag / 2.5 * sin(f * t)
	$CreditsText.position.y += mag / 4 * cos(f / 3 * t)

	#$ResurgeLogo.rotation = mag / 2.5 * cos(f * t)
	#$ResurgeLogo.position.y += mag / 4 * sin(f / 3 * t)
	#$ResurgeLogo.scale = Vector2.ONE * (scale_factor / 4)

	$PlayButtonHolder.rotation = mag / 5 * cos(f * t)
	$PlayButtonHolder.position.y += 2 * mag * sin(5 * f * t)
	$PlayButtonHolder.scale = Vector2.ONE * (scale_factor * 2)

	$ControlButtonHolder.rotation = mag / 5 * sin(f * t)
	$ControlButtonHolder.position.y += 2 * mag * cos(5 * f * t)
	$ControlButtonHolder.scale = Vector2.ONE * (scale_factor * 2)

	# PlayerSim run loop
	if player_waiting:
		player_timer += delta
		if player_timer >= WAIT_TIME:
			player_waiting = false
			$PlayerSim.visible = true
	else:
		var pos = $PlayerSim.position
		pos.x += RUN_SPEED * delta * player_direction
		pos.y = SCREEN_HEIGHT / 2 + PATH_AMPLITUDE * sin(t * 2.0)
		$PlayerSim.position = pos

		$PlayerSim.flip_h = player_direction == -1

		if (player_direction == 1 and pos.x > SCREEN_WIDTH + 20) or (player_direction == -1 and pos.x < -20):
			reset_player()

func reset_player():
	player_waiting = true
	player_timer = 0.0
	player_direction *= -1

	var start_x = -20 if player_direction == 1 else SCREEN_WIDTH + 20
	$PlayerSim.position = Vector2(start_x, SCREEN_HEIGHT / 2)
	$PlayerSim.visible = false
	$PlayerSim.play("run") # Replace "run" with your actual animation name

func _on_texture_button_pressed() -> void:
	$Cover.get_node("AnimationPlayer").play("FadeOut")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_control_button_pressed() -> void:
	$Cover.get_node("AnimationPlayer").play("FadeOut")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/controls.tscn")
