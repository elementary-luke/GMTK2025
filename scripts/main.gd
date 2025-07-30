extends Node2D

var segments = []
var seg_len = 2.5
var nsegments = 50

func _ready():
	for i in range(0, nsegments):
		var inst = Segment.new()
		inst.initialise(Vector2(0.0, seg_len * i))
		segments.append(inst)

func _physics_process(delta: float) -> void:
	draw_rope()
	simulate()
	
func draw_rope():
	$Rope.points = segments.map(func(a): return a.pos)

func simulate():
	for i in range(0, len(segments)):
		var seg = segments[i]
		var velo = seg.pos - seg.old_pos
		velo *= 0.5
		seg.old_pos = seg.pos
		seg.pos += velo
		seg.pos.y += 0.0
	
	for i in range(0, 10):
		apply_constraints()
	
func apply_constraints():
	var first_seg = segments[0]
	first_seg.pos = $Player.global_position
	
	segments[-1].pos = Vector2(0, 0)
	for i in range(0, len(segments) - 1):
		var a = segments[i]
		var b = segments[i + 1]

		var delta = b.pos - a.pos
		var dist  = delta.length()
		if dist == 0: 
			continue
		var error = dist - seg_len
		var n     = delta / dist
		var corr  = n * (error * 0.5)

		if i == 0:
			# head anchored
			b.pos -= n * error
		else:
			a.pos += corr
			b.pos -= corr
