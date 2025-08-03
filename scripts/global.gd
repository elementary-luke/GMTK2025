extends Node

var Root
var Player
var Rope

const RED = Color8(255, 23, 0)
const GREEN = Color8(255, 255, 255)
const INCREASE_GREEN = Color8(87, 211, 49)


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
	inst.default_color = INCREASE_GREEN
	inst.points = points
	Root.add_child(inst)
