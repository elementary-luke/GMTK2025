extends Node

var Root
var Player
var Rope

const RED = Color8(226, 54, 54)
const GREEN = Color8(54, 255, 111)


var despawn_distance = 1024.0 # how far away a bullet or enemy is before it despawns
var score = 0.0
var rope_used = 0.0
var time_lived = 0.0

var player_position : Vector2

var cut_line = preload("res://scenes/cut_line.tscn")

func show_cut_line(points):
	var inst = cut_line.instantiate()
	inst.default_color = RED
	inst.points = points
	Root.add_child(inst)

func show_loop_line(points):
	var inst = cut_line.instantiate()
	inst.default_color = GREEN
	inst.points = points
	Root.add_child(inst)
