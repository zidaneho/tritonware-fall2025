extends Node2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var normal_audio = $NormalButtonAudio
@onready var dark_audio = $DarkButtonAudio

@export var weapons: Array[WeaponData]

var playerFound = false
var buttonPressed = false
var player

func _ready():
	
	# Connect the 'clicked' signal from the AnimatedSprite2D script (animatedButton.gd)
	# to this script's 'press' function.
	buttonPressed = DataManager.get_button_pressed()
	
	anim_sprite.play("default")
	
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and playerFound:
		press()

func press():
	
	if (!buttonPressed):
		print("clicked")
		# Play "pressed" animation
		anim_sprite.play("pressed")
		
		# Play sound
		dark_audio.play()
		
		# once per day
		buttonPressed = true
		DataManager.start_new_game()
		await get_tree().create_timer(3)
		get_tree().quit()
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	playerFound = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	playerFound = false
