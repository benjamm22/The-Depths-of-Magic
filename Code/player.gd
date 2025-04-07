extends CharacterBody3D

@export var spell_sound : PackedScene
@export var hit_sound : PackedScene
@export var defeat_scene : Control
@export var cam : Camera3D
@export var shoot_point : Node3D

@onready var anim = %AnimationTree
@export var mesh = MeshInstance3D

@export var fireball_scene : PackedScene  #file path for projectile

var base_spell_width
var spell_width #currently a cone infront of the character
var spell_count #Number of projectiles spawned
var spell_rate #seconds betwwen shots
var spell_damage
var spell_speed 
var spell_duration
var health
var move_speed

@export var max_health = 20
@export var start_speed = 5
@export var start_spell_width = 5
@export var start_spell_count = 1
@export var start_spell_rate = 1.0
@export var start_spell_damage = 2
@export var start_spell_speed = 5
@export var start_spell_duration = .5
@export var start_move_speed = 5

var knockback = Vector3()
@export var knock_back_amount = 200.0

var time_since_last_shot = 99 #99 so its always more than rate at start #a hold to make sure it doesnt break
var is_shooting = false #Toggle for rapid fire or survivors style
var dying = false;
var base_spread = 15
var angle_per_projectile = 8

const SPEED = 10.0


func reset_stats():
	dying = false
	anim.set("parameters/StateMachine/conditions/dying", false)
	health = max_health
	spell_width = start_spell_width
	spell_count = start_spell_count
	spell_rate = start_spell_rate
	spell_damage = start_spell_damage
	spell_speed = start_spell_speed
	spell_duration = start_spell_duration
	move_speed = start_move_speed

func _ready() -> void:
	reset_stats()

func _process(delta):
	if not dying:
		look_at_aim()
		auto_shoot(delta)

func _physics_process(delta):
	if not dying:
		if not is_on_floor():
			velocity.y -= 10.0
		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
		velocity += (Vector3(knockback.x, 0.0, knockback.z) * delta)
		
		move_and_slide()


#this function finds the local movement direction relative to the direction being faced 
#this makes it so even though Y axis is up - facing left knows moving on Y axis locally is moving right aka X axis
#this is just for the animation tree bullsh
#func direction_relative_to_rotation(dir, delta):
	#if dir:
		#var forward = -transform.basis.z.normalized()
		#var right = transform.basis.x.normalized()
		#var local_move = (dir.y * forward + dir.x * right).normalized()
		#smooth = lerp(smooth, Vector2(local_move.x, local_move.z), SPEED * delta)
	#else:
		#smooth = smooth
	#return smooth


func aim():
	#get raycast of mouse and look at it
	if get_mouse_world_position() != null: #this 'if' might fix random crash? Godot not finding mouse fast enough I think???
		var aim_pos = get_mouse_world_position()
		if aim_pos:
			var player_pos = global_transform.origin
			var distance = player_pos.distance_to(aim_pos)
			aim_pos.y = player_pos.y # fix horizontal look
			var dir = (aim_pos - player_pos).normalized()
			return dir
	return Vector3.ZERO # dont nothing if bad aim


func look_at_aim():
	var dir = aim()
	if dir:
		look_at(global_transform.origin + dir, Vector3.UP)


func shoot_fireball(amount, base_spread, angle_per_projectile):
	anim.set("parameters/StateMachine/BlendTree/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	spawn_sound(spell_sound)
	var base_dir = aim()
	if base_dir == Vector3.ZERO:
		return #dont shoot if bad aim
	var shoot_pos = shoot_point.global_transform.origin
	# Calculate total spread angle based on number of projectiles
	var total_spread = base_spread + angle_per_projectile * (amount - 1)
	for i in range(amount):
		var t = 0.0
		if amount > 1:
			t = float(i) / float(amount - 1)  # 0.0 to 1.0 across all projectiles
		var angle_offset_deg = lerp(-total_spread / 2.0, total_spread / 2.0, t)
		var angle_offset_rad = deg_to_rad(angle_offset_deg)
		# Rotate around Y-axis for horizontal fan
		var rot = Basis(Vector3.UP, angle_offset_rad)
		var dir = (rot * base_dir).normalized()
		#Spawn the fireball
		var fireball = fireball_scene.instantiate()
		get_tree().current_scene.add_child(fireball)
		fireball.global_transform.origin = shoot_pos + dir * .25# spawn in front for now
		fireball.direction = dir
		fireball.speed = spell_speed
		fireball.duration = spell_duration
		fireball.damage = spell_damage
		
		

func _input(event):
	if event.is_action_pressed("shoot"):
		is_shooting = true
		
		
	elif event.is_action_released("shoot"):
		is_shooting = false
		

func get_mouse_world_position():
	#raycast for mouse
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * 1000  # Cast ray 1000 units forward
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position  # This is the 3D point where the ray hits
	else:
		return null  # Ray didn't hit anything

func auto_shoot(delta):
	time_since_last_shot += delta
	if is_shooting:
		#time_since_last_shot += delta
		if time_since_last_shot >= spell_rate:
			shoot_fireball(spell_count, spell_width, angle_per_projectile)
			time_since_last_shot = 0.0
	#else: # not needed, since we increase time_since_last_shot at top of method
		# Reset timer when not shooting so it feels responsive
		#time_since_last_shot = spell_rate
		#time_since_last_shot += delta


func take_damage(damage, dir):
	health -= damage
	spawn_sound(hit_sound)
	flash()
	var look_dir = aim()
	#can overwrite it by moving
	var tween = create_tween()
	tween.tween_property(self, "knockback", dir * knock_back_amount, .15)
	tween.tween_property(self, "knockback", Vector3.ZERO, .15)
	if(health <= 0):
		anim.set("parameters/StateMachine/conditions/dying", true)
		dying = true
		await get_tree().create_timer(2).timeout
		defeat_scene.show()
		get_tree().paused = true
	
	
func reset_position():
	global_position.x = .5
	global_position.z = .5


func flash():
	#only doing robe it looks just fine and easier to code
	var tween = create_tween()
	var mat = mesh.mesh.surface_get_material(1)
	tween.tween_property(mat, "shader_parameter/flash_amount", 1.0, .1)
	tween.tween_property(mat, "shader_parameter/flash_amount", 0.0, .1)
	
func spawn_sound(sound):
	var sfx = sound.instantiate()
	get_tree().current_scene.add_child(sfx)
	sfx.global_transform.origin = global_transform.origin
