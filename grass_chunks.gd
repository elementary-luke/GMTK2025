@tool
extends Node2D

@export var frame_index: int = 0:
	set(value):
		frame_index = value
		update_frame()

func _ready():
	update_frame()

func update_frame():
	if $AnimatedSprite2D:
		$AnimatedSprite2D.frame = frame_index
