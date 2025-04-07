extends Node3D

var damage = 1
var speed = 10
var duration = 1
var direction = Vector3.ZERO
@onready var spin_control = $"orbit control"
var spin_speed = 500


func _ready():
	await get_tree().create_timer(duration).timeout
	self.queue_free()


func _process(delta):
	look_at(global_position + direction)
	global_translate(direction * speed * delta)
	spin_control.rotation_degrees.z += spin_speed * delta
	


func _on_area_3d_area_entered(area):
	if(area.get_parent().is_in_group("Player")):
		area.get_parent().take_damage(damage, direction)
		self.queue_free()
