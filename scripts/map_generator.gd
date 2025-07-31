extends Node2D

var room_scene : PackedScene
@export var room_size := Vector2i(512, 512)
@export var generation_radius := 2  # Adjust as needed
@export var cleanup_radius := 3     # Adjust as needed

var room_num = 3

var spawned_rooms := {}
var last_room := Vector2i(-9999, -9999)  # ensure first spawn triggers

func _process(_delta):
	if Global.player_position == null:
		return

	# Your version of current_room calculation (working for you)
	var current_room = Vector2i(Global.player_position) / room_size

	if current_room != last_room:
		generate_rooms_around(current_room)
		clean_up(current_room)
		last_room = current_room

func generate_rooms_around(center: Vector2i):
	for x in range(-generation_radius, generation_radius + 1):
		for y in range(-generation_radius, generation_radius + 1):
			var coords = center + Vector2i(x, y)
			if not spawned_rooms.has(coords):
				spawn_room(coords)

func spawn_room(coords: Vector2i):
	var rand = randi_range(1, room_num)
	
	if rand == 1:
		room_scene = preload("res://scenes/rooms/room1.tscn")
	if rand == 2:
		room_scene = preload("res://scenes/rooms/room2.tscn")
	if rand == 3:
		room_scene = preload("res://scenes/rooms/room3.tscn")
	
	var room = room_scene.instantiate()
	room.position = coords * room_size
	add_child(room)
	spawned_rooms[coords] = room

func clean_up(current_room: Vector2i):
	var to_remove := []
	for coords in spawned_rooms.keys():
		if coords.distance_to(current_room) > cleanup_radius:
			to_remove.append(coords)

	for coords in to_remove:
		spawned_rooms[coords].queue_free()
		spawned_rooms.erase(coords)
