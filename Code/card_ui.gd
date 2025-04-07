extends Control

@export var song : AudioStreamPlayer
@export var level : Node3D
var playerFromTree
var spawnerFromTree
@export var BlueTitle : RichTextLabel
@export var BlueText : RichTextLabel
@export var GreenTitle : RichTextLabel
@export var GreenText : RichTextLabel
@export var RedTitle : RichTextLabel
@export var RedText : RichTextLabel

var SpellRateTitle = "Cooldown"
var SpellRateText = "Increase how often you shoot spells while attacking"
var SpellCountTitle = "Multiply"
var SpellCountText = "Increase the number of spells shot per attack"
var SpellWidthTitle = "Spread"
var SpellWidthText = "Increase the spread of your spells"
var SpellDamageTitle = "Damage"
var SpellDamageText = "Increase the damage of your spells"
var SpellDistanceTitle = "Distance"
var SpellDistanceText = "Increase how far your spells travel"
var SpellSpeedTitle = "Speed"
var SpellSpeedText = "Increase how fast your spells travel"
var PlayerHealthTitle = "Vitality"
var PlayerHealthText = "Increase how much health you have"
var PlayerSpeedTitle = "Agility"
var PlayerSpeedText = "Increase how fast you move"

var powerTitleList = [SpellRateTitle, SpellCountTitle, SpellWidthTitle, SpellDamageTitle, SpellDistanceTitle, SpellSpeedTitle, PlayerHealthTitle, PlayerSpeedTitle]
var powerTextList = [SpellRateText, SpellCountText, SpellWidthText, SpellDamageText, SpellDistanceText, SpellSpeedText, PlayerHealthText, PlayerSpeedText]
var indiciesOfPower = powerTitleList.size() - 1

var selection = 0
var currentBlue = 0
var currentGreen = 0
var currentRed = 0
var pastBlue = 0
var pastGreen = 0
var pastRed = 0


var randomNumberGenerator = RandomNumberGenerator.new()

func _on_draw() -> void:
	get_tree().paused = true
	# set current and text for cards
	# If we want to not get same choice for two cards just chekc the random nubmer
	# If we want to not ge the same choice on same color twice in a row, use the "past" var's I've set up
	# this might be useful too powerList.pick_random() 
	pastBlue = currentBlue
	pastGreen = currentGreen
	pastRed = currentRed	
	currentBlue = randomNumberGenerator.randi_range(0, indiciesOfPower)
	currentGreen = randomNumberGenerator.randi_range(0, indiciesOfPower)
	currentRed = randomNumberGenerator.randi_range(0, indiciesOfPower)
	
	BlueTitle.text = powerTitleList[currentBlue]
	BlueText.text = powerTextList[currentBlue]
	GreenTitle.text = powerTitleList[currentGreen]
	GreenText.text = powerTextList[currentGreen]
	RedTitle.text = powerTitleList[currentRed]
	RedText.text = powerTextList[currentRed]

func _on_hidden() -> void:
	get_tree().paused = false
	# not sure we need this, keeping it in case	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#to test functionality, uncomment these
	self.hide()
	playerFromTree = get_tree().get_first_node_in_group("Player")
	spawnerFromTree = get_tree().get_first_node_in_group("Spawner")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func UpgradePlayerPower() -> void:
	if(selection == 0):
		playerFromTree.spell_rate *= .9
		level.cooldown += 1
	elif(selection == 1):
		playerFromTree.spell_count += 1
		level.multiply += 1
	elif(selection == 2):
		playerFromTree.spell_width += 5
		level.spread += 1
	elif(selection == 3):
		playerFromTree.spell_damage += 1
		level.damage += 1
	elif(selection == 4):
		playerFromTree.spell_duration += .2
		level.distance += 1
	elif(selection == 5):
		playerFromTree.spell_speed += 1
		level.speed += 1
	elif(selection == 6):
		playerFromTree.max_health += 5
		level.vitality += 1
	elif(selection == 7):
		playerFromTree.move_speed += 1
		level.agility += 1

func ApplyPower(cardColor: String) -> void:
	# increase a player value, and the correct color
	if(cardColor == "Blue"):
		selection = currentBlue
	elif(cardColor == "Green"):
		selection = currentGreen
	elif (cardColor == "Red"):
		selection = currentRed
	level.depth += 1
	song.pitch_scale *= .95
	UpgradePlayerPower()
	self.hide()
	#
	# MAKE THE PLAYER HEALTH RESET - NEEDS A NEW VAR TO TRACK MAX HEALTH
	#
	playerFromTree.health = playerFromTree.max_health
	playerFromTree.reset_position()
	spawnerFromTree.next_room()
	

func _on_blue_button_button_up() -> void:
	ApplyPower("Blue")
	
func _on_green_card_button_up() -> void:
	ApplyPower("Green")

func _on_red_card_button_up() -> void:
	ApplyPower("Red")
