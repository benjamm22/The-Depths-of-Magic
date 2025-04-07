extends Control

@onready var PlayButton = $"Panel/HBoxContainer/Middle Section/Play Button"
@onready var muteButton = $"Panel/HBoxContainer/RightSection/Mute Button"
@onready var volume_image = $"Panel/HBoxContainer/RightSection/Mute Button/TextureRect"
@onready var volume_slider = $"Panel/HBoxContainer/RightSection/volume slider"
var soundPath = "res://Art/ui/Sound.png"
var mutePath = "res://Art/ui/Mute.png"
var Sound = true
var volume = AudioServer.get_bus_index("Master")

func _on_hidden() -> void:
	#get_tree().paused = false
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(volume))
	get_tree().paused = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("pause")):
		PlayButton.text = "Continue"
		get_tree().paused = !get_tree().paused
		self.visible = !self.visible
	pass


func _on_mute_button_button_up() -> void:
	AudioServer.set_bus_mute(volume, not AudioServer.is_bus_mute(volume))
	if(Sound):
		volume_image.texture = ResourceLoader.load(mutePath)
		Sound = false;
	else:
		volume_image.texture = ResourceLoader.load(soundPath)
		Sound = true;


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)
	pass # Replace with function body.


func _on_play_button_button_up() -> void:
	self.hide()
	get_tree().paused = false
	pass # Replace with function body.


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(volume, linear_to_db(volume_slider.value))
