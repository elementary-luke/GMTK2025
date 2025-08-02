extends Node2D
var segments = []
var seg_len = 10.0
var start_nsegments = 10
var start_pos = Vector2(0.0, 0.0)
var segments_in_loop = 10
var rope_phy_iterations = 20
var collision_radius = 2.0
var intersection_counter = 0
var intersection_max = 10

func _ready() -> void:
	Global.Rope = self
	$Line.texture_mode = Line2D.LINE_TEXTURE_TILE
			
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
		intersection_counter += 1
		if intersection_counter > intersection_max:
			handle_intersection()
			intersection_counter = 0
	

func handle_intersection():
	var ip = self_intersecting()
	if !ip:
		return
		
	var i = ip[0]
	var j = ip[1] + 2
	if j - i > segments_in_loop:
		$Loop.points = $Line.points.slice(i, j)
		Global.Player.casting_rope = false
		Global.show_cut_line($Line.points.slice(0, i + 1) + $Line.points.slice(j))
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
	
	resolve_collisions()
	
	if Global.Player.moving:
		for i in range(0, rope_phy_iterations):
			apply_distance_constraints()
			if i % 10 == 0:
				resolve_collisions()
		
		for i in range(0, rope_phy_iterations):
			apply_smoothing_constraints()
			if i % 10 == 0:
				resolve_collisions()
		
	resolve_collisions()

func resolve_collisions():
	var space_state = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = collision_radius  # Adjust based on rope thickness

	for seg in segments:
		
		var shape_query = PhysicsShapeQueryParameters2D.new()
		shape_query.shape = shape
		shape_query.transform.origin = seg.pos
		shape_query.collision_mask = 1 << 2  # Use your wall layer
		
		var result = space_state.intersect_shape(shape_query)
		if result:
			#var position = result.position
			# Push the segment slightly out of the wall
			seg.pos = seg.old_pos #position + normal * 5.0

func apply_distance_constraints():
	segments[0].pos = start_pos
	if get_rope_length() > max_length():
		Global.Player.global_position = segments[-1].pos
		Global.Player.no_move = true
	else:
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
	var min_d_index = -1

	for i in range(0, segments.size() - 1):
		
		if (i == 0 || i == segments.size() - 1) && len(segments) > 2:
			continue
		var d = pos.distance_squared_to(segments[i].pos)
		if d < min_dist_sq && segments[i].scissor == null and segments[i - 1].scissor == null and segments[i + 1].scissor == null:
			min_dist_sq = d
			min_d_index = i

	return min_d_index

func cut(cut_index):
	if cut_index == segments.size() - 2 || cut_index == segments.size() - 1:
		for i in segments:
			if i.scissor != null:
				i.scissor.reset()
		segments.clear()
		Global.Player.casting_rope = false
		$Line.clear_points()
		return
		
	Global.show_cut_line(segments.slice(0, cut_index + 1).map(func(x): return x.pos))

	for i in range(0, cut_index + 1):
		if segments[0].scissor != null:
			segments[0].scissor.reset()
	
		if i != cut_index:
			segments.remove_at(0)
		else:
			segments[0].scissor = null
			
	#segments = segments.slice(cut_index)
	for i in range(0, len(segments)):
		if segments[i].scissor != null:
			segments[i].scissor.seg_index  = i
		
	start_pos = segments[0].pos

func get_rope_length() -> float:
	var length := 0.0
	for i in range(segments.size() - 1):
		length += segments[i].pos.distance_to(segments[i + 1].pos)
	return length
