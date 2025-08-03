extends CharacterBody2D

var bullet_scn = preload("res://scenes/projectiles/blaster_bullet.tscn")
var bullet_speed = 10.0
var charging_up = false
var warning_time = 0.2
var pred_move_speed = 10.0
var focus_point = Vector2(0, 0)
var attack_range = 500.0
var rope_value = 10.0
var dead = false

func _ready() -> void:
	focus_point = Global.player_position

func _physics_process(delta: float) -> void:
	if dead:
		return
		
	if charging_up:
		var future_player_pos = predicted_player_position()
		
		var diff = future_player_pos - focus_point
		
		if diff.length() > pred_move_speed:
			focus_point += diff.normalized() * pred_move_speed
		else:
			focus_point = future_player_pos
			
		var show_pos = focus_point + (focus_point - $ShootPos.global_position).normalized() * 3000.0
		
		$TerrainCast.target_position = Vector2(show_pos - $TerrainCast.global_position)
		$TerrainCast.force_raycast_update()
		if $TerrainCast.is_colliding():
			show_pos = $TerrainCast.get_collision_point()
		$Line2D.global_position = Vector2(0.0, 0.0)
		$Line2D.points = [$ShootPos.global_position, show_pos]
		
	if $Sprite2D.animation not in ["attack_side", "attack_front", "attack_back"]:
		var diff = (Global.player_position - $ShootPos.global_position)
		$Sprite2D.flip_h = false
		if abs(diff.x) > abs(diff.y):
			if diff.x < 0:
				$Sprite2D.flip_h = true
			$Sprite2D.play("idle_side")
		else:
			if diff.y >= 0:
				$Sprite2D.play("idle_front")
			else:
				$Sprite2D.play("idle_back")
	
	if $ShootPos.global_position.distance_to(Global.player_position) > Global.despawn_distance:
		queue_free()

func _on_charge_up_timer_timeout() -> void:
	$Line2D.default_color = Color(1.0, 0.0, 0.0)
	charging_up = false


	var show_pos = focus_point + (focus_point - $ShootPos.global_position).normalized() * 3000.0
	
	$TerrainCast.target_position = Vector2(show_pos - $TerrainCast.global_position)
	$TerrainCast.force_raycast_update()
	if $TerrainCast.is_colliding():
		show_pos = $TerrainCast.get_collision_point()
	$Line2D.global_position = Vector2(0.0, 0.0)
	$Line2D.points = [$ShootPos.global_position, show_pos]
	
	var ediff = (Global.player_position - $ShootPos.global_position)
	$Sprite2D.flip_h = false
	
	if abs(ediff.x) > abs(ediff.y):
		if ediff.x < 0:
			$Sprite2D.flip_h = true
		$Sprite2D.play("attack_side")
	else:
		if ediff.y >= 0:
			$Sprite2D.play("attack_front")
		else:
			$Sprite2D.play("attack_back")
	
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.hide()
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.show()
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.hide()
	await get_tree().create_timer(warning_time / 4.0).timeout
	$Line2D.show()

	
	var inst = bullet_scn.instantiate()
	inst.position = $ShootPos.global_position
	
	inst.dir = (focus_point - $ShootPos.global_position).normalized()
	inst.speed = bullet_speed

	Global.Root.add_child(inst)
	
	var time = (focus_point - $ShootPos.global_position).length() / (bullet_speed * 60.0)
	
	await get_tree().create_timer(time).timeout
	
	$Line2D.default_color = Color(1.0, 1.0, 1.0)
	$Line2D.hide()
	
	$RestTimer.start()

func _on_rest_timer_timeout() -> void:
	if $ShootPos.global_position.distance_to(Global.player_position) < 300.0:
		$Line2D.global_position = Vector2(0.0, 0.0)
		focus_point = Global.player_position
		
		$TerrainCast.target_position = Vector2(focus_point - $TerrainCast.global_position)
		$TerrainCast.force_raycast_update()
		if $TerrainCast.is_colliding():
			focus_point = $TerrainCast.get_collision_point()
		
		$Line2D.points = [$ShootPos.global_position, focus_point]
		charging_up = true
		$ChargeUpTimer.start()
		$Line2D.show()
	else:
		$RestTimer.start()
	

func predicted_player_position():
	var inst = bullet_scn.instantiate()
	inst.position = $ShootPos.global_position

	var p = Global.Player
	var shooter_pos = $ShootPos.global_position
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
	dead = true
	if !Global.Root.game_ended:
		Global.Player.add_rope(rope_value)
	
	$Sprite2D.play("death")
	await get_tree().create_timer(0.4).timeout
	if !Global.Root.game_ended:
		Global.Root.gain_label(rope_value, global_position)
		
	queue_free()


func _on_sprite_2d_animation_finished() -> void:
	if $Sprite2D.animation not in ["attack_back", "attack_front", "attack_side"]:
		return
	
	$Sprite2D.play("idle_front")
		
