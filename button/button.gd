extends Node2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var normal_audio = $NormalButtonAudio
@onready var dark_audio = $DarkButtonAudio

var playerFound = false
var buttonPressed = false

func _ready():
	# Connect the 'clicked' signal from the AnimatedSprite2D script (animatedButton.gd)
	# to this script's 'press' function.
	anim_sprite.clicked.connect(press) 
	buttonPressed = DataManager.get_button_pressed()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fire") and playerFound:
		press()

func press():
	if (!buttonPressed):
		# Play "pressed" animation
		anim_sprite.play("pressed")
		
		# Play sound
		normal_audio.play()
		
		# once per day
		buttonPressed = true
		DataManager.set_button_pressed(true)
		
		# someone dies
		
		
		# random chance of weapon
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	playerFound = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	playerFound = false
