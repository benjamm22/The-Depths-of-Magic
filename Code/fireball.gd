extends Node3D

var damage = 1
var speed = 10
var duration = .5
var direction = Vector3.ZERO
@export var fire_particles : PackedScene


func _ready():
	var clone = fire_particles.instantiate()
	add_child(clone)
	clone.global_position = global_position
	await get_tree().create_timer(duration).timeout
	self.queue_free()


func _process(delta):
	global_translate(direction * speed * delta)
	
	


func _on_area_3d_area_entered(area):
	if area.is_in_group("Enemy"):
		area.get_parent().take_damage(damage)
		self.queue_free()


func _on_area_3d_body_entered(body):
	if body.is_in_group("Obstacle"):
		self.queue_free()
