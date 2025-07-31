extends Node2D

func _ready():
	Global.Root = self
	$Player.segments = Global.Rope.segments

func _physics_process(delta: float) -> void:
	$Player.update(delta)
	$Rope.update(delta)
