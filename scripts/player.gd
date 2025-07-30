extends CharacterBody2D

var move = Vector2(0.0, 0.0)
var speed = 2.0

func _physics_process(delta: float) -> void:
	var intent = Vector2(0.0, 0.0)
	intent.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	intent.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	position += intent * Vector2(speed, speed)
