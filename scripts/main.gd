extends Node2D

var scissor = preload("res://scenes/enemies/scissor.tscn")
var hit_label_scn = preload("res://scenes/hit_label.tscn")
var gain_label_scn = preload("res://scenes/gain_label.tscn")
var rope_shown = 0.0
var score_shown = 0.0
var game_ended = false

func _ready():
	Global.Root = self
	$Player.segments = $Rope.segments
	rope_shown = $Player.rope_left
	Global.rope_used = 0.0
	Global.time_lived = 0.0
	Global.score = 0.0
	

func _physics_process(delta: float) -> void:
	if !game_ended:
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
	var label = $UI/AmmoHolder/AmmoLabel
	#var amount_meters = ceil(lerp(0, 100, percentage_left))
	rope_shown = lerp(rope_shown, $Player.rope_left , 0.1)
	#print(percentage_left, rope_shown, amount_meters)
	label.text = str(int(round(rope_shown))) + "m"
	
	score_shown = lerp(score_shown, Global.score, 0.1)
	$UI/ScoreHolder/ScoreLabel.text = str(int(round(score_shown)))
	$UI/AmmoHolder.modulate = lerp($UI/AmmoHolder.modulate, Color(1.0, 1.0, 1.0), 0.1)
	$UI/AmmoPivot/AmmoPoly.modulate = lerp($UI/AmmoPivot/AmmoPoly.modulate, Color(1.0, 1.0, 1.0), 0.1)
	$UI/ScoreHolder.modulate = lerp($UI/ScoreHolder.modulate, Color(1.0, 1.0, 1.0), 0.1)


func ammo_red():
	$UI/AmmoPivot/AmmoPoly.modulate = Global.RED
	$UI/AmmoHolder.modulate = Global.RED

func ammo_green():
	$UI/AmmoPivot/AmmoPoly.modulate = Global.GREEN
	$UI/AmmoHolder.modulate = Global.GREEN

func end_game():
	game_ended = true
	$Player/AnimatedSprite2D.play("idle_forward")
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
	var inst = hit_label_scn.instantiate()
	inst.global_position = $Player.global_position - Vector2(0.0, 30)
	inst.modulate = Global.RED
	inst.scale = Vector2(size, size)
	inst.get_node("Label").text = "-%s" % int(dmg)
	add_child(inst)

func gain_label(amount, pos):
	#var size = 1.0
	#size = lerp(1.0, 1.5, amount / 10.0)
	var inst = gain_label_scn.instantiate()
	inst.global_position = pos - Vector2(0.0, lerp(15, 25, amount / 10.0))
	inst.modulate = Global.GREEN
	#inst.scale = Vector2(size, size)
	inst.get_node("Holder/Label").text = "+%s" % int(amount)
	add_child(inst)

func score_gain_label(amount, multiplier):
	var inst = $UI/ScoreGainLabel
	inst.modulate = Global.GREEN
	
	inst.amount = amount
	inst.multiplier = multiplier
	inst.set_labels()
		
	inst.get_node("AnimationPlayer").play("Fade")
	
	#$UI.add_child(inst)
	await get_tree().create_timer(0.95).timeout
	Global.score += amount * multiplier
	$UI/ScoreHolder.modulate = Global.GREEN

func multi_label(multiplier, pos):
	var inst = gain_label_scn.instantiate()
	inst.global_position = pos
	inst.modulate = Global.GREEN
	inst.scale = Vector2(2.0, 2.0)
	inst.get_node("Holder/Label").text = "X%s" % int(multiplier)
	add_child(inst)
