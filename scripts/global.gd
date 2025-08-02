extends Node

var Root
var Player
var Rope

var score = 0.0
var rope_used = 0.0
var time_lived = 0.0

var player_position : Vector2

var cut_line = preload("res://scenes/cut_line.tscn")

func show_cut_line(points):
	var inst = cut_line.instantiate()
	inst.points = points
	Root.add_child(inst)
