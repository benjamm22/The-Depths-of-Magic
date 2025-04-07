extends Node3D

@export var Camera : Camera3D
@export var Ground : StaticBody3D
@export var Wall1 : StaticBody3D
@export var Wall2 : StaticBody3D
@export var Wall3 : StaticBody3D
@export var Wall4 : StaticBody3D
@export var Door1 : StaticBody3D
@export var Door2 : StaticBody3D
@export var Door3 : StaticBody3D
@export var BottomlessPit : StaticBody3D

#@export var Pillar : StaticBody3D
@export var nav_region : NavigationRegion3D
@export var PillarScene : PackedScene  #one of several obsticals
@export var DoorScene : PackedScene
@export var Size : int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#camera
	Camera.position.x = 0
	Camera.position.y = Size * .75
	Camera.position.z = Size * .33
	Camera.look_at(Vector3(0,0,0))
	
	
	
	# ground and wall scaling and position
	Ground.scale.x = Size
	Ground.scale.y = .1
	Ground.scale.z = Size
	
	Wall1.scale.x = Size
	Wall1.scale.y = Size
	Wall1.position.z = -Size / 2
	Wall2.scale.x = Size
	Wall2.scale.y = Size
	Wall2.position.z = Size / 2	
	Wall3.scale.y = Size
	Wall3.scale.z = Size
	Wall3.position.x = Size / 2
	Wall4.scale.y = Size
	Wall4.scale.z = Size
	Wall4.position.x = -Size / 2
	
	# door1.scale # base this of camera maybe?
	var mainDoor = DoorScene.instantiate()
	get_tree().current_scene.find_child("NavRegion").add_child(mainDoor) 
	mainDoor.global_transform.origin.z = -1 * ((Size - 1) / 2)
	#Door1.position.z = -1 * ((Size - 1) / 2) # straight ahead of camera
	Door1.position.z = 0
	Door2.position.x = -1 * ((Size - 1) / 2)
	Door3.position.x = (Size - 1) / 2
	
	#spawning here for testing, trigger off of something later
	
	# obsticals - only some per scene, budget goes up after x number of levels
	#var pillarShapeBudget : int = 2 # idea to0 complex, K.I.S.S.
	var pillar1Position = Vector3(Size  / 3, Size / 2, Size / 3)
	var pillar2Position = Vector3(Size  / 3, Size / 2, -Size / 3)
	var pillar3Position = Vector3(-Size  / 3, Size / 2, -Size / 3)
	var pillar4Position = Vector3(-Size  / 3, Size / 2, Size / 3)
	var pillarHeight = Size / 2
	var pillarWidth = Size / 50
	
	var pillar1 = PillarScene.instantiate()
	get_tree().current_scene.find_child("NavRegion").add_child(pillar1) 
	pillar1.global_position = pillar1Position
	pillar1.scale.y = pillarHeight
	pillar1.scale.x = pillarWidth
	pillar1.scale.z = pillarWidth
	var pillar2 = PillarScene.instantiate()
	get_tree().current_scene.find_child("NavRegion").add_child(pillar2) 
	pillar2.global_transform.origin = pillar2Position
	pillar2.scale.y = pillarHeight
	pillar2.scale.x = pillarWidth
	pillar2.scale.z = pillarWidth
	var pillar3 = PillarScene.instantiate()
	get_tree().current_scene.find_child("NavRegion").add_child(pillar3) 
	pillar3.global_transform.origin = pillar3Position
	pillar3.scale.y = pillarHeight
	pillar3.scale.x = pillarWidth
	pillar3.scale.z = pillarWidth
	var pillar4 = PillarScene.instantiate()
	get_tree().current_scene.find_child("NavRegion").add_child(pillar4) 
	pillar4.global_transform.origin = pillar4Position
	pillar4.scale.y = pillarHeight
	pillar4.scale.x = pillarWidth
	pillar4.scale.z = pillarWidth
	
	var pitWidth = Size / 10
	var pitHeight = pitWidth * .02
	BottomlessPit.position.x = 0
	BottomlessPit.position.y = 0
	BottomlessPit.position.z = 0
	BottomlessPit.scale.x = pitWidth
	BottomlessPit.scale.y = pitHeight
	BottomlessPit.scale.z = pitWidth
	
	
	print(Camera.position)
	
	# debug
	#print(pillar1.global_position)
	#print(Wall1.position.z)
	#print(Wall3.position.x)
	#print(Wall4.position.x)
	#print(Door1.position.z)
	#print(Wall3.position.x)
	#print(Wall4.position.x)
	await get_tree().process_frame # wait 1 frame to bake nav mesh
	nav_region.bake_navigation_mesh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
