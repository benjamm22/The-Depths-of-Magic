extends NavigationRegion3D

var baked = 1
@export var Bookshelf : StaticBody3D # change these to static bodies
@export var Table : StaticBody3D
@export var Bench : StaticBody3D
@export var spawns : Node3D
var available_spawns = []
var all_spawns = []
var items = [Bookshelf, Table, Bench]

func _ready():
	items = [Bookshelf, Table, Bench]
	reset_spawns()
	bake()

func _process(delta):
	pass

func bake():
	reset_spawns()
	for item in items:
		var pick = available_spawns.pick_random()
		var rotation_random = randf_range(0.0, 360.0)
		if pick:
			item.global_transform.origin = pick.global_transform.origin
			item.rotation.y = rotation_random
			available_spawns.erase(pick)
	reset_spawns()
	await get_tree().process_frame
	bake_navigation_mesh()

func reset_spawns():
	available_spawns = spawns.get_children()
