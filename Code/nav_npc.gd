extends CharacterBody3D

@export var attack_sound : PackedScene
@export var hit_sound : PackedScene
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var animation = $wumb2/AnimationPlayer
@export var mesh : MeshInstance3D
var dying = false
var spawner
var player
var depth
var MAX_SPEED = 5
var speed = MAX_SPEED
var HEALTH = 6
@export var attacking = false
var damage = 3
var can_attack = false

func _ready():
	spawner = get_tree().get_first_node_in_group("Spawner")
	player = get_tree().get_first_node_in_group("Player")
	$"Attack Box/CollisionShape3D".disabled = true
	

func _process(delta):
	if can_attack and not dying:
		attacking = true
		animation.play("wumb attack")
		look_direction()
	if dying:
		$Hitbox.monitorable = false
	elif not dying:
		$Hitbox.monitorable = true
	if player:
		get_player_location()
	


func _physics_process(delta):
	if player and not attacking and not dying:
		animation.play("wumb walk")
		if attacking:
			speed = 0
		else:
			speed = MAX_SPEED
		velocity = look_direction() * speed
		move_and_slide()


func get_player_location():
	var player_position := Vector3.ZERO
	player_position.x = player.global_transform.origin.x
	player_position.z = player.global_transform.origin.z
	navigation_agent_3d.set_target_position(player_position)
	return player_position


func take_damage(damage):
	HEALTH -= damage
	flash()
	spawn_sound(hit_sound)
	if HEALTH < 1 and not dying:
		dying = true
		#warning said to change to this deferred thing idk what it does - didn't bother looking it up - works tho
		$"Attack Box/CollisionShape3D".set_deferred("disabled", true)
		$CollisionShape3D.set_deferred("disabled", true)
		spawner.enemy_count -= 1
		spawner.wave_count -= 1
		#print("Enemy dying, decreaseing enemy count " , spawner.enemy_count)
		#print("Enemy dying, decreaseing wave count " , spawner.wave_count)
		spawner.check_room()
		animation.play("wumb die")
		await animation.animation_finished
		get_tree().current_scene.kills += 1
		self.queue_free()

func look_direction():
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination =  destination - global_transform.origin
	var direction = local_destination.normalized()
	if transform.origin != destination: #fixes error/warning
		look_at(destination)
	return direction



func _on_attack_body_entered(body):
	if not dying:
		if body.is_in_group("Player"):
			can_attack = true


func _on_attack_box_area_entered(area):
	if(area.get_parent().is_in_group("Player")):
		var dir = look_direction()
		area.get_parent().take_damage(damage, dir)
		spawn_sound(attack_sound)


func _on_attack_range_body_exited(body):
		if body.is_in_group("Player"):
			can_attack = false


func flash():
	#only doing robe it looks just fine and easier to code
	var tween = create_tween()
	var tween2 = create_tween()
	var mat0 = mesh.mesh.surface_get_material(0)
	var mat1 = mesh.mesh.surface_get_material(1)
	tween.tween_property(mat0, "shader_parameter/flash_amount", 1.0, .1)
	tween.tween_property(mat0, "shader_parameter/flash_amount", 0.0, .1)
	tween2.tween_property(mat1, "shader_parameter/flash_amount", 1.0, .1)
	tween2.tween_property(mat1, "shader_parameter/flash_amount", 0.0, .1)

func spawn_sound(sound):
	var sfx = sound.instantiate()
	get_tree().current_scene.add_child(sfx)
	sfx.global_transform.origin = global_transform.origin
	
