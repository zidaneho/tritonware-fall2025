class_name NPCData extends Resource

@export var npc_name : String
@export var npc_description : String
@export var icon : Texture2D
@export var special_dialogue_map : Array[SpecialDialogueMapping]
@export var normal_dialogues : Array[DialogueResource]

func get_dialogue_to_play(current_heart_level : int):
	for special_dialogue in special_dialogue_map:
		if special_dialogue.heart_level == current_heart_level:
			return special_dialogue.dialogue
	if normal_dialogues.size() <= 0:
		return null
	var rand_index = randi_range(0,normal_dialogues.size()-1)
	return normal_dialogues[rand_index]
	
