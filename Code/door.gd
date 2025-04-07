extends StaticBody3D

var CardUI
@onready var anim1 = $door_left/AnimationPlayer
@onready var anim2 = $door_right/AnimationPlayer
var spawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardUI = get_tree().current_scene.find_child("Card UI")
	spawner = get_tree().current_scene.find_child("Enemy Spawner")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_area_entered(area: Area3D) -> void:
	if(area.get_parent().is_in_group("Player")):
		if not spawner.room_active:
			CardUI.show()
			spawner.room_active = true

func close_doors():
	anim1.play_backwards("open door left")
	anim2.play_backwards("open door right")

func open_doors():
	anim1.play("open door left")
	anim2.play("open door right")
