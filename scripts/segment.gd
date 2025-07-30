extends Node
class_name Segment

var pos
var old_pos

func initialise(p : Vector2):
	self.pos = p
	self.old_pos = p
	return self
