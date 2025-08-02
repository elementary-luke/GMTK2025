extends CharacterBody2D

var bullet_scn = preload("res://scenes/projectiles/blaster_bullet.tscn")
var bullet_speed = 10.0
var charging_up = false
var warning_time = 0.2
var pred_move_speed = 10.0
var focus_point = Vector2(0, 0)
var attack_range = 500.0
var rope_value = 10.0

func _ready() -> void:
	focus_point = Global.Player.global_position

func _physics_process(delta: float) -> void:
	if charging_up:
		var future_player_pos = predicted_player_position()
		
		var diff = future_player_pos - focus_point
		
		if diff.length() > pred_move_speed:
			focus_point += diff.normalized() * pred_move_speed
		else:
			focus_point = future_player_pos
			
		var show_pos = focus_point + (focus_point - global_position).normalized() * 3000.0
		
		$TerrainCast.target_position = Vector2(show_pos - $TerrainCast.global_position)
		$TerrainCast.force_raycast_update()
		if $TerrainCast.is_colliding():
			show_pos = $TerrainCast.get_collision_point()
		$Line2D.global_position = Vector2(0.0, 0.0)
		$Line2D.points = [global_position, show_pos]

func _on_charge_up_timer_timeout() -> void:
	$Line2D.default_color = Color(1.0, 0.0, 0.0)
	charging_up = false


	var show_pos = focus_point + (focus_point - global_position).normalized() * 3000.0
	
	$TerrainCast.target_position = Vector2(show_pos - $TerrainCast.global_position)
	$TerrainCast.force_raycast_update()
	if $TerrainCast.is_colliding():
		show_pos = $TerrainCast.get_collision_point()
	$Line2D.global_position = Vector2(0.0, 0.0)
	$Line2D.points = [global_position, show_pos]
	
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.hide()
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.show()
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.hide()
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.show()
	
	var inst = bullet_scn.instantiate()
	inst.position = global_position


	inst.dir = (focus_point - global_position).normalized()
	inst.speed = bullet_speed

	Global.Root.add_child(inst)
	
	var time = (focus_point - global_position).length() / (bullet_speed * 60.0)
	await get_tree().create_timer(time).timeout
	
	$Line2D.default_color = Color(1.0, 1.0, 1.0)
	$Line2D.hide()
	
	$RestTimer.start()

func _on_rest_timer_timeout() -> void:
	if global_position.distance_to(Global.Player.global_position) < 300.0:
		$Line2D.global_position = Vector2(0.0, 0.0)
		focus_point = Global.Player.global_position
		
		$TerrainCast.target_position = Vector2(focus_point - $TerrainCast.global_position)
		$TerrainCast.force_raycast_update()
		if $TerrainCast.is_colliding():
			focus_point = $TerrainCast.get_collision_point()
		
		$Line2D.points = [global_position, focus_point]
		charging_up = true
		$ChargeUpTimer.start()
		$Line2D.show()
	else:
		$RestTimer.start()
	

func predicted_player_position():
	var inst = bullet_scn.instantiate()
	inst.position = global_position

	var p = Global.Player
	var shooter_pos = global_position
	var player_pos = p.global_position
	var player_vel = p.move_step   # units per frame
	var b_speed = bullet_speed * 60.0        # units per frame

	# Direction vector from shooter to player
	var to_player = player_pos - shooter_pos
	var distance = to_player.length()

	# Estimate relative velocity direction (player motion toward shooter)
	var player_speed_toward = to_player.normalized().dot(player_vel)

	var approach_speed = b_speed - player_speed_toward

	var t: float = 0.0
	if approach_speed > 0.001:
		t = distance / approach_speed + warning_time
	else:
		t = 0.0  # fallback to immediate shot

	return player_pos + player_vel * t

func die():
	if Global.Player.rope_left > 0:
		Global.Player.add_rope(rope_value)

	queue_free()
