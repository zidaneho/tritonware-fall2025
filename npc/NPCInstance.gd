extends Node2D

@export var npc_data : NPCData
@export var npc_id : String

var current_title_idx = 0

func _ready() -> void:
	if npc_id.is_empty():
		push_error("NPC %s has no id set" % [name])

func interact():
	var current_heart_level = DataManager.get_heart_level(npc_id)
	var dialogue_to_play = npc_data.get_dialogue_to_play(current_heart_level)
	if dialogue_to_play:
		DialogueManager.show_dialogue_balloon(dialogue_to_play,"start"+str(current_title_idx))
	
