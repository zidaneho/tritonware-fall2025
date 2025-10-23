extends Control

signal cutscene_finished

@onready var dialogue_label: Label = $DialogueLabel
@onready var music_player: AudioStreamPlayer2D = $MusicPlayer

const BASE_LINE_DELAY: float = 3.0 # The default duration (1.0x) in seconds.
const FADE_TIME: float = 1.5       # Time (in seconds) for music to fade in/out.

# The array of dialogue entries. Each entry is a Dictionary with:
# - "text": The line to display.
# - "time_mult": A multiplier for the BASE_LINE_DELAY.
const DIALOGUE: Array[Dictionary] = [
	# intro
	{"text": "What do you desire?", "time_mult": 1.0},
	{"text": "Honor and pride?", "time_mult": 1.0}, 
	{"text": "Riches beyond your imagination?", "time_mult": 1.0},
	{"text": "Protection for the ones you love? ", "time_mult": 1.0}, 
	{"text": "Whatever it is, the button can grant you...", "time_mult": 2.0},
	{"text": "But beware...", "time_mult": 2.9},
	# verse 1
	{"text": "There once was a knight,", "time_mult": 1.0},
	{"text": "Noble of heart and pure of intent.", "time_mult": 1.0},
	{"text": "Proudly defending their homeland,", "time_mult": 1.0},
	{"text": "Wielding their blade against the storm.", "time_mult": 1.0},
	{"text": "The foe stretched to the horizon's rim,", "time_mult": 1.0},
	{"text": "All courage was spent, with no place left to hide.", "time_mult": 1.0},
	{"text": "But hidden deep, a button was found,", "time_mult": 1.0},
	{"text": "They pressed it once, and fresh steel filled their hand!", "time_mult": 1.0},
	# verse 2
	{"text": "But the cost for such a gift would soon be born,", "time_mult": 1.0},
	{"text": "For every flash of steel, the town paid the toll.", "time_mult": 1.0},
	{"text": "They pressed it until they were unstoppable, ", "time_mult": 1.0},
	{"text": "And looked up to find they had erased their world.", "time_mult": 1.0},
	{"text": "Why?", "time_mult": 1.0},
	{"text": "How?", "time_mult": 1.0},
	{"text": "It doesn’t matter.", "time_mult": 1.0},
	{"text": "It’s all over.", "time_mult": 1.0}
]

func _ready() -> void:
	music_player.play()
	start_cutscene()

func start_cutscene() -> void:
	# Ensure the UI is visible initially
	self.visible = true
	dialogue_label.text = ""
	
	# Start music playback
	music_player.play()
	
	for dialogue_entry in DIALOGUE:
		var line: String = dialogue_entry.text
		var multiplier: float = dialogue_entry.get("time_mult", 1.0) 
		var actual_delay: float = BASE_LINE_DELAY * multiplier
		
		# Display the current line
		dialogue_label.text = line
		print("Displaying: " + line + " | Waiting for: " + str(actual_delay) + "s")
		
		# Wait for the specified duration
		await get_tree().create_timer(actual_delay).timeout
		
	# Clean up
	self.visible = false
	music_player.stop()
	
	# Emit the signal
	cutscene_finished.emit()
