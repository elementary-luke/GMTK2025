extends Node2D

var segment = preload("res://scenes/segment.tscn")

func _ready():
	var last = segment.instantiate()
	print(last.get_node("PinJoint2D").node_a)
	last.get_node("PinJoint2D").node_b = $Player.get_path()
	last.position.y = 20
	print(last.get_node("PinJoint2D").node_b)
	$Segments.add_child(last)
	
	for i in range(0, 100):
		var inst = segment.instantiate()
		inst.position.y = last.position.y + 20
		inst.get_node("PinJoint2D").node_b = last.get_path()
		$Segments.add_child(inst)
		last = inst
