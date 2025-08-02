extends Node2D

var scissor = preload("res://scenes/scissor.tscn")
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
	rope_shown = ceil(lerp(rope_shown, $Player.rope_left , 0.1))
	#print(percentage_left, rope_shown, amount_meters)
	label.text = str(int(rope_shown)) + "m"
	
	score_shown = ceil(lerp(score_shown, Global.score, 0.1))
	$UI/ScoreLabel.text = str(int(score_shown))
	$UI/AmmoPivot/AmmoPoly.modulate.g = lerp($UI/AmmoPivot/AmmoPoly.modulate.g, 1.0, 0.2)
	$UI/AmmoPivot/AmmoPoly.modulate.b = lerp($UI/AmmoPivot/AmmoPoly.modulate.b, 1.0, 0.2)


func ammo_red():
	$UI/AmmoPivot/AmmoPoly.modulate.g = 0.0
	$UI/AmmoPivot/AmmoPoly.modulate.b = 0.0
