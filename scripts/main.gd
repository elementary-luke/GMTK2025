extends Node2D

var scissor = preload("res://scenes/enemies/scissor.tscn")
var hit_label_scn = preload("res://scenes/dissapearing_label.tscn")
var rope_shown = 0.0
var score_shown = 0.0

func _ready():
	Global.Root = self
	$Player.segments = $Rope.segments
	rope_shown = $Player.rope_left
	Global.rope_used = 0.0
	Global.time_lived = 0.0
	Global.score = 0.0
	

func _physics_process(delta: float) -> void:
	if $Player.rope_left > 0:
		$Player.update(delta)
		$Rope.update(delta)
	ui()
	
func _on_scissor_timer_timeout() -> void:
	var inst = scissor.instantiate()
	inst.global_position.x = $Player.global_position.x + randf_range(-50.0, 50.0)
	inst.global_position.y = $Player.global_position.y + randf_range(-50.0, 50.0)
	add_child(inst)

func ui():
	var percentage_left = $Player.rope_left / $Player.max_rope
	var bar = $UI/AmmoPivot
	bar.scale.x = lerp(bar.scale.x, percentage_left, 0.1)
	var label = $UI/AmmoLabel
	#var amount_meters = ceil(lerp(0, 100, percentage_left))
	rope_shown = lerp(rope_shown, $Player.rope_left , 0.1)
	#print(percentage_left, rope_shown, amount_meters)
	label.text = str(int(rope_shown)) + "m"
	
	score_shown = lerp(score_shown, Global.score, 0.1)
	$UI/ScoreLabel.text = str(int(score_shown))
	$UI/AmmoPivot/AmmoPoly.modulate.g = lerp($UI/AmmoPivot/AmmoPoly.modulate.g, 1.0, 0.2)
	$UI/AmmoPivot/AmmoPoly.modulate.b = lerp($UI/AmmoPivot/AmmoPoly.modulate.b, 1.0, 0.2)


func ammo_red():
	$UI/AmmoPivot/AmmoPoly.modulate = Color8(226, 54, 54)

func end_game():
	Global.Rope.cut(Global.Rope.segments.size() - 1)
	get_tree().call_group("Enemy", "die")
	get_tree().call_group("Bullet", "die")
	$ScissorTimer.stop()
	await get_tree().create_timer(1.0).timeout
	get_tree().create_tween()
	var tween = get_tree().create_tween()
	tween.tween_property($Player/Shadow, "scale", Vector2(0, 0), 0.2)
	$Player/AnimatedSprite2D.play("death")

func _on_animated_sprite_2d_animation_finished() -> void:
	if $Player.rope_left <= 0:
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

func hit_label(dmg):
	var size = 1.0
	size = lerp(1.0, 1.5, dmg / 10.0)
	var inst = hit_label_scn.instantiate()
	inst.global_position = $Player.global_position - Vector2(0.0, lerp(15, 25, dmg / 10.0))
	inst.modulate = Color8(226, 54, 54)
	inst.scale = Vector2(size, size)
	inst.get_node("Label").text = "-%s" % dmg
	add_child(inst)
