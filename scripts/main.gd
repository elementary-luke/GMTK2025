extends Node2D

var scissor = preload("res://scenes/scissor.tscn")

func _ready():
	Global.Root = self
	$Player.segments = Global.Rope.segments

func _physics_process(delta: float) -> void:
	$Player.update(delta)
	$Rope.update(delta)
	
func _on_scissor_timer_timeout() -> void:
	var inst = scissor.instantiate()
	inst.global_position.x = $Player.global_position.x + randf_range(-50.0, 50.0)
	inst.global_position.y = $Player.global_position.y + randf_range(-50.0, 50.0)
	add_child(inst)
