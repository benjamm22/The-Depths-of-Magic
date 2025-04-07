extends Node3D

@export var wumb : PackedScene
@export var bug : PackedScene
@export var imp : PackedScene

var enemy_type = []

var enemy_type_count = enemy_type.size() - 1

@export var nav_region : NavigationRegion3D
@export var starting_enemy_count = 10
@export var enemy_count = starting_enemy_count
@export var door1 : StaticBody3D
@export var door2 : StaticBody3D
@export var depth = 1
var room_active = false
var wave_active = false

var wave_count = 0


func _ready():
	enemy_type = [wumb, imp, bug]
	await get_tree().create_timer(3.0).timeout
	spawn_wave()
	check_room()
	
func _process(delta):
	pass

func next_room():
	door1.close_doors()
	door2.close_doors()
	nav_region.bake()
	await get_tree().create_timer(2.0).timeout
	depth += 1
	starting_enemy_count += 2
	enemy_count = starting_enemy_count
	spawn_wave()
	check_room()

func check_room():
	if wave_count > 0:
		wave_active = true
	if wave_count <= 0:
		wave_active = false
	if enemy_count > 0:
		room_active = true
	if enemy_count <= 0:
		room_active = false
	
	if not wave_active and room_active:
		wave_active = true
		spawn_wave()
	
	if not room_active:
		door1.open_doors()
		door2.open_doors()
	
func spawn_wave():
	wave_active = true
	wave_count = get_wave_count(depth)
	await get_tree().create_timer(1.0).timeout
	if wave_count < enemy_count:
		for i in wave_count:
			spawn_enemy()
	else:
		wave_count = enemy_count
		for i in enemy_count:
			spawn_enemy()


func spawn_enemy():
	var random_enemy = enemy_type.pick_random()
	var enemy = random_enemy.instantiate()
	enemy.depth = depth
	get_tree().current_scene.add_child(enemy)
	var random_position = get_random_position(nav_region)
	enemy.global_transform.origin = random_position
	

func get_random_position(nav_region) -> Vector3:
	var nav_map = nav_region.get_navigation_map()
	var bounds = nav_region.get_bounds()
	var max_attempts = 10
	for i in range(max_attempts):
		var random_position = Vector3(
			randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
			0, # You can customize Y height as needed
			randf_range(bounds.position.z, bounds.position.z + bounds.size.z)
		)

		# Snap this point to the closest point on the navmesh
		var closest_point = NavigationServer3D.map_get_closest_point(nav_map, random_position)

		# Check if it's reasonably close (i.e., it's on the navmesh)
		if (random_position - closest_point).length() < 1.0:
			return closest_point
	
	# Fallback: return center of nav bounds if no good point was found
	return bounds.position + bounds.size * 0.5

func get_wave_count(room):
	var max_per_wave = 5 + room
	var min_per_wave = (2 + (room / 2))
	var rand_wave_count = floor(randf_range(min_per_wave, max_per_wave))
	return rand_wave_count
	
