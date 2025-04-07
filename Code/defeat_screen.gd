extends Control

@onready var info = $"Panel/HBoxContainer/Left Section/Info"
@onready var volume_image = $"Panel/HBoxContainer/RightSection/Mute Button2/TextureRect"
var soundPath = "res://Art/ui/Sound.png"
var mutePath = "res://Art/ui/Mute.png"
@export var level : Node3D
@export var player : CharacterBody3D
@export var spawner : Node3D
var Sound = true
var volume = AudioServer.get_bus_index("Master")
@onready var volume_slider = $"Panel/HBoxContainer/RightSection/volume slider"

func _ready() -> void:
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(volume))
	hide()

func _on_retry_button_button_up() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_button_up() -> void:
	get_tree().quit()


func _process(delta: float) -> void:
	var kills = level.kills
	var depth = level.depth
	var cooldown = level.cooldown
	var multiply = level.multiply
	var spread = level.spread
	var damage = level.damage
	var distance = level.distance
	var speed = level.speed
	var vitality = level.vitality
	var agility = level.agility
	info.text = "Number of Kills: " + str(kills) + "\n\n" + "Depth: " + str(depth) + "\n\n\n\n" + "Cooldown Upgrades: " + str(cooldown) \
		+ "\n\n" + "Multiply Upgrades: " + str(multiply) + "\n\n" + "Spread Upgrades: " + str(spread) + "\n\n" + "Damage Upgrades: " + str(damage) \
		+ "\n\n" + "Distance Upgrades: " + str(distance) + "\n\n" + "Speed Upgrades: " + str(speed) + "\n\n" + "Spell Speed Upgrades: " + str(speed) \
		+ "\n\n" + "Vitality Upgrades: " + str(vitality) + "\n\n" + "Agility Upgrades: " + str(agility)


func _on_mute_button_2_button_up() -> void:
	AudioServer.set_bus_mute(volume, not AudioServer.is_bus_mute(volume))
	if(Sound):
		volume_image.texture = ResourceLoader.load(mutePath)
		Sound = false;
	else:
		volume_image.texture = ResourceLoader.load(soundPath)
		Sound = true;


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(volume, linear_to_db(volume_slider.value))
