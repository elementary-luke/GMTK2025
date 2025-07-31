extends Node2D

var segments = []
var seg_len = 5.0
var start_nsegments = 5
var start_pos = Vector2(0.0, 0.0)

func _ready():
	Global.Root = self
	for i in range(0, start_nsegments):
		var inst = Segment.new()
		inst.initialise(Vector2(0.0, 0.0))
		segments.insert(0, inst)

func max_length():
	return seg_len * segments.size()

func add_segment():
	var inst = Segment.new()
	inst.initialise($Player.global_position)
	segments.append(inst)
	
func update(delta: float) -> void:
	simulate()
	draw_rope()

func draw_rope():
	var draw_points = segments.map(func(a): return a.pos) + [$Player.global_position]
	$Rope.points = draw_points
	
	var th = 1
	var dist = segments[-th].pos.distance_to(segments[0].pos)
	
	var min = max_length() - th * seg_len
	var max = max_length() + seg_len
	print(dist, " ", min, " ", max)
	if dist >= max_length() - th * seg_len:
		#print(dist)
		pass
	else:
		pass

func simulate():
	for i in range(0, len(segments)):
		var seg = segments[i]
		var velo = seg.pos - seg.old_pos
		velo *= 0.2
		seg.old_pos = seg.pos
		seg.pos += velo
		seg.pos.y += 0.0
	
	for i in range(0, 10):
		apply_constraints()
		
	#if (segments[-1].pos - $Player.global_position).length() > seg_len:
		#add_segment()
	
func apply_constraints():
	var first_seg = segments[0]
	first_seg.pos = start_pos
	
	if segments[-1].pos.distance_to($Player.global_position) > seg_len:
		var offset = (segments[-1].pos - $Player.global_position).normalized() * seg_len
		segments[-1].pos = $Player.global_position + offset
	
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
	
		if i == 0: #make sure starting point never moves
			b.pos -= n * error
		else:
			a.pos += corr
			b.pos -= corr
