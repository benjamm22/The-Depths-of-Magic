extends CharacterBody3D

@onready var navigation_agent_3d = $NavigationAgent3D
@onready var animation = $imp2/AnimationPlayer
@onready var raycast = $RayCast3D
@export var hit_sound : PackedScene
@export var imp_bolt_scene : PackedScene
@export var mesh : MeshInstance3D
@export var attack_sound : PackedScene
var dying = false
var spawner
var player
var depth
var speed = 6
var MAX_SPEED = 5
var HEALTH = 4
@export var attacking = false
var damage = 1
var can_attack = false

func _ready():
	spawner = get_tree().get_first_node_in_group("Spawner")
	player = get_tree().get_first_node_in_group("Player")
	

func _process(delta):
	if can_attack and not dying:
		attacking = true
		animation.play("imp attack")
		look_direction()
	if dying:
		$Hitbox.monitorable = false
	elif not dying:
		$Hitbox.monitorable = true
	if player:
		get_player_location()
	#????? Godot being rude
	if not dying:
		check_raycast()

func _physics_process(delta):
	if player and not attacking and not dying:
		animation.play("imp walk")
		if attacking:
			speed = 0
		else:
			speed = MAX_SPEED
		velocity = look_direction() * speed
		move_and_slide()


func get_player_location():
	var player_position := Vector3.ZERO
	player_position.x = player.global_position.x
	player_position.z = player.global_position.z
	navigation_agent_3d.set_target_position(player_position)
	return player_position


func take_damage(damage):
	HEALTH -= damage
	flash()
	spawn_sound(hit_sound)
	if HEALTH < 1 and not dying:
		dying = true
		#warning said to change to this deferred thing idk what it does - didn't bother looking it up - works tho
		$Hitbox/CollisionShape3D.set_deferred("disabled", true)
		$CollisionShape3D.set_deferred("disabled", true)
		spawner.enemy_count -= 1
		spawner.wave_count -= 1
		#print("Enemy dying, decreaseing enemy count " , spawner.enemy_count)
		#print("Enemy dying, decreaseing wave count " , spawner.wave_count)
		spawner.check_room()
		animation.play("imp die")
		await animation.animation_finished
		get_tree().current_scene.kills += 1
		self.queue_free()

func check_raycast():
	if raycast != null:
		if raycast.get_collider() != null:
			if raycast.is_colliding():
				if raycast.get_collider().is_in_group("Player"):
					can_attack = true
				else:
					can_attack = false
			elif not raycast.is_colliding():
				can_attack = false


func look_direction():
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination =  destination - global_position
	var direction = local_destination.normalized()
	if transform.origin != destination: #fixes error/warning
		look_at(destination)
	return direction


func _on_attack_range_body_exited(body):
		if body.is_in_group("Player"):
			can_attack = false


func _on_attack_range_body_entered(body):
	if not dying:
		if body.is_in_group("Player"):
			#can_attack = true
			pass

func flash():
	#only doing robe it looks just fine and easier to code
	var tween = create_tween()
	var tween2 = create_tween()
	var mat1 = mesh.mesh.surface_get_material(1)
	var mat2 = mesh.mesh.surface_get_material(2)
	tween.tween_property(mat1, "shader_parameter/flash_amount", 1.0, .1)
	tween.tween_property(mat1, "shader_parameter/flash_amount", 0.0, .1)
	tween2.tween_property(mat2, "shader_parameter/flash_amount", 1.0, .1)
	tween2.tween_property(mat2, "shader_parameter/flash_amount", 0.0, .1)

func shoot_imp_ball():
	var imp_bolt = imp_bolt_scene.instantiate()
	get_tree().current_scene.add_child(imp_bolt)
	imp_bolt.global_transform.origin = $"Bolt Point".global_transform.origin
	imp_bolt.direction = global_position.direction_to(player.global_position)
	spawn_sound(attack_sound)
	#imp_bolt.speed = spell_speed
	#imp_bolt.duration = spell_duration
	imp_bolt.damage = damage


func spawn_sound(sound):
	var sfx = sound.instantiate()
	get_tree().current_scene.add_child(sfx)
	sfx.global_position = global_position
