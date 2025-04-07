extends CPUParticles3D

var dad

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dad = get_parent()
	reparent(get_tree().current_scene)
	global_position = dad.global_position
	direction = Vector3(0,0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dad != null:
		direction = -dad.direction
		global_position = dad.global_position
	else:
		queue_free()
