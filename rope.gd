extends Node2D
var segments = []
var seg_len = 5.0
var start_nsegments = 10
var start_pos = Vector2(0.0, 0.0)
var segments_in_loop = 10

func _ready() -> void:
	Global.Rope = self
	$Line.texture_mode = Line2D.LINE_TEXTURE_TILE
	#for i in range(0, start_nsegments):
			#var inst = Segment.new()
			#inst.initialise(Vector2(0.0, 0.0))
			#segments.insert(0, inst)
func max_length():
	return seg_len * segments.size()

func add_segment():
	var inst = Segment.new()
	inst.initialise(Global.Player.global_position)
	segments.append(inst)
	
func update(delta: float) -> void:
	if Global.Player.casting_rope:
		simulate()
		draw_rope()
		handle_intersection()
	

func handle_intersection():
	var ip = self_intersecting()
	if !ip:
		return
		
	var i = ip[0]
	var j = ip[1] + 2
	if j - i > segments_in_loop:
		$Loop.points = $Line.points.slice(i, j)
		Global.Player.casting_rope = false
		$CutLine.points = $Line.points.slice(0, i + 1) + $Line.points.slice(j)
		$Line.clear_points()
		segments.clear()
		
		for b in query_bodies_in_polygon($Loop.points):
			var body = b["collider"]
			if body:
				body.queue_free()

func draw_rope():
	var draw_points = segments.map(func(a): return a.pos)
	$Line.points = draw_points
	
	var th = 1
	var dist = segments[-th].pos.distance_to(segments[0].pos)
	
	var min = max_length() - th * seg_len
	var max = max_length() + seg_len
	#print(dist, " ", min, " ", max)
	if dist >= max_length() - th * seg_len:
		#print(dist)
		pass
	else:
		pass

func simulate():
	for i in range(0, len(segments)):
		var seg = segments[i]
		var velo = seg.pos - seg.old_pos
		velo *= 0.00
		seg.old_pos = seg.pos
		seg.pos += velo
		seg.pos.y += 0.0
	
	if Global.Player.moving:
		for i in range(0, 20):
			apply_distance_constraints()
		
		
		for i in range(0, 20):
			apply_smoothing_constraints()
		
	#if (segments[-1].pos - $Player.global_position).length() > seg_len:
		#add_segment()
	
func apply_distance_constraints():
	var first_seg = segments[0]
	first_seg.pos = start_pos
	segments[-1].pos = Global.Player.global_position
	
	#if segments[-1].pos.distance_to(Global.Player.global_position) > seg_len:
		#var offset = (segments[-1].pos - Global.Player.global_position).normalized() * seg_len
		#segments[-1].pos = Global.Player.global_position + offset
	
	for i in range(0, len(segments) - 1):
		var a = segments[i]
		var b = segments[i + 1]
	
		var delta = b.pos - a.pos
		var dist  = delta.length()
		if dist == 0: 
			continue
		var error = dist - seg_len
		if i == len(segments) - 2 and segments[i].pos.distance_to(segments[i + 1].pos) <= seg_len:
			error = dist - segments[i].pos.distance_to(segments[i + 1].pos)
			
		var n = delta / dist
		var corr  = n * (error * 0.5)
	
		if i == 0: #make sure starting point never moves
			b.pos -= n * error
		else:
			a.pos += corr
			b.pos -= corr
		
func apply_smoothing_constraints():
	for i in range(0, len(segments) - 1):
		var A = segments[i - 1].pos
		var B = segments[i].pos
		var C = segments[i + 1].pos
		
		if i == len(segments) - 1:
			C = B
		elif i == 0:
			A = B

		var target = (A + B + C) / 3.0
		segments[i].pos = lerp(segments[i].pos, target, 0.1)

func self_intersecting():
	# We have N points → N-1 segments [0→1], [1→2], …, [N-2→N-1]
	var seg_count = segments.size() - 1
	if seg_count < 3:
		return false   # fewer than 3 segments can't self-intersect
	
	# For each segment i
	for i in range(seg_count):
		var a1 = segments[i].pos
		var a2 = segments[i + 1].pos
		
		# And each segment j that is at least 2 away (to skip adjacent)
		for j in range(i + 2, seg_count):
			# If rope is open, also skip the very last vs. first segment
			if i == 0 and j == seg_count - 1:
				continue
			var b1 = segments[j].pos
			var b2 = segments[j + 1].pos
			
			# Check for intersection
			var ip = Geometry2D.segment_intersects_segment(a1, a2, b1, b2)
			if ip:
				return [i, j, ip]
	return false
	

func query_bodies_in_polygon(points) -> Array:
	# Build a shape from points
	var shape = ConvexPolygonShape2D.new()
	shape.points = points


	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D.IDENTITY  # no extra transform
	params.collide_with_bodies = true
	params.collision_mask = 1 << 1

	return get_world_2d().direct_space_state.intersect_shape(params)
	
func get_nearest_point(pos):
	var closest_point = Vector2.ZERO
	var min_dist_sq = INF
	var min_d_index = 0

	for i in range(1, segments.size() - 2):
		var d = pos.distance_squared_to(segments[i].pos)
		if d < min_dist_sq:
			min_dist_sq = d
			min_d_index = i

	return min_d_index
