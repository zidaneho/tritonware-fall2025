extends Node2D

@export var dialogue_resource : DialogueResource

@export var speech_mount : Marker2D

func start_dialogue():
	if dialogue_resource:
		var balloon = DialogueManager.show_dialogue_balloon(dialogue_resource)
	else:
		print_debug("ERROR: No dialogue resource has been assigned to this node.")
