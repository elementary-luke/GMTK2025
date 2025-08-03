extends Node2D

var hit_label_scn = preload("res://scenes/hit_label.tscn")
var gain_label_scn = preload("res://scenes/gain_label.tscn")
var rope_shown = 0.0
var score_shown = 0.0
var game_ended = false
var enemy_scene : PackedScene
var max_enemies = 5

				   #[blaster, carrot_blaster, peashooter, scissor mouse, spinshooter]
var probabilities = [8,        8,             20,         50,            15]
var cooldowns     = [8.0,     8.0,            4.0,        1.0,         4.0]
var adjust        = [true,     true,          false,      false,         true]

var difficulty = 1.0
var difficulty_increase = 0.0002
var max_difficulty = 3.0

func _ready():
	$CoverLayer/Cover.get_node("AnimationPlayer").play("FadeIn")
	Global.Root = self
	$Player.segments = $Rope.segments
	rope_shown = $Player.rope_left
	Global.rope_used = 0.0
	Global.time_lived = 0.0
	Global.score = 0.0
	
	
	$Player/RectContainer.hide()

func _physics_process(delta: float) -> void:
	if !game_ended:
		$Player.update(delta)
		$Rope.update(delta)
		difficulty = min(difficulty + difficulty_increase, max_difficulty)
	ui()

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
	$UI/AmmoPivot/AmmoPoly.modulate = Global.INCREASE_GREEN
	$UI/AmmoHolder.modulate = Global.INCREASE_GREEN

func end_game():
	game_ended = true
	$Player/AnimatedSprite2D.play("idle_forward")
	Global.Rope.cut(Global.Rope.segments.size() - 1)
	get_tree().call_group("Enemy", "die")
	get_tree().call_group("Bullet", "die")
	$EnemyTimer.stop()
	
	$Player/RectContainer.show()
	$Player/RectContainer/ColorRect.material.set_shader_parameter("holeCenter", Global.player_position - Vector2(0, 10))
	await get_tree().create_timer(1).timeout
	get_tree().create_tween()
	$Player/RectContainer/ColorRect/AnimationPlayer.play("GoIn")
	await get_tree().create_timer(0.5).timeout
	$Player/AnimatedSprite2D.play("death")
	var tween = get_tree().create_tween()
	tween.tween_property($Player/Shadow, "scale", Vector2(0, 0), 0.2)
	await get_tree().create_timer(1).timeout
	$Player/RectContainer/ColorRect/AnimationPlayer.play("GoIn2")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if $Player/AnimatedSprite2D.animation == "spawn":
		$Player/AnimatedSprite2D.play("idle_forward")

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
	$UI/ScoreHolder.modulate = Global.INCREASE_GREEN

func multi_label(multiplier, pos):
	var inst = gain_label_scn.instantiate()
	inst.global_position = pos
	inst.modulate = Global.GREEN
	inst.scale = Vector2(2.0, 2.0)
	inst.get_node("Holder/Label").text = "X%s" % int(multiplier)
	add_child(inst)


func _on_enemy_timer_timeout() -> void:
	if game_ended:
		return
		
	if $Enemies.get_child_count() > max_enemies * difficulty:
		$EnemyTimer.start(4.0)
		return
		
	var adj_probabilities = probabilities.duplicate(true)
	
	for i in range(len(adjust)):
		if adjust[i]:
			adj_probabilities[i] = adj_probabilities[i] * difficulty
	
	var sum_probabilites = 0
	for i in adj_probabilities:
		sum_probabilites += i
	
	var type = 0
	var r = randi_range(0, sum_probabilites - 1)

	for i in adj_probabilities.size():
		if r < adj_probabilities[i]:
			type = i
			break
		r -= adj_probabilities[i]
	
	if type == 0:
		enemy_scene = preload("res://scenes/enemies/blaster.tscn")
	elif type == 1:
		enemy_scene = preload("res://scenes/enemies/carrot_blaster.tscn")
	elif type == 2:
		enemy_scene = preload("res://scenes/enemies/peashooter.tscn")
	elif type == 3:
		enemy_scene = preload("res://scenes/enemies/scissor.tscn")
	elif type == 4:
		enemy_scene = preload("res://scenes/enemies/spinshooter.tscn")
		
	var inst = enemy_scene.instantiate()
	
	var pos  = Vector2(0, 0)
	pos.x = $Player.global_position.x + randi_range(-200, 200)
	pos.y = $Player.global_position.y + randi_range(-100, 100)
	
	var space_state = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = 16
	
	for i in range(0, 100):
		var shape_query = PhysicsShapeQueryParameters2D.new()
		shape_query.shape = shape
		shape_query.transform.origin = pos
		shape_query.collision_mask = 1 << 2  # Use your wall layer
		
		var result = space_state.intersect_shape(shape_query)
		if !result:
			break
		
	inst.global_position = pos
	
	$Enemies.add_child(inst)
	
	$EnemyTimer.start(cooldowns[type] / difficulty)
