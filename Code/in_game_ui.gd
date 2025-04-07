extends Control

@export var player : CharacterBody3D
@onready var pb = $ProgressBar

func _ready() -> void:
	pb.max_value = player.max_health
	pb.value = pb.max_value
	pb.min_value = 0.0

func _process(delta: float) -> void:
	pb.value = player.health
	pb.value = clamp(pb.value, pb.min_value, pb.max_value)
