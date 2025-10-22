extends Node2D

@export var npc_data : NPCData
@export var npc_id : String
@export var loop_titles : bool = false

var current_title_idx = 0
var current_balloon : Node
var current_dialogue_resource : DialogueResource
var terminate_balloon_radius : float = 200
var canceled_dialogue_by_distance : bool = false
var player : Node2D


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(on_dialogue_end)
	if npc_id.is_empty():
		push_error("NPC %s has no id set" % [name])

func _process(_delta: float) -> void:
	if current_balloon != null and global_position.distance_to(player.global_position) > terminate_balloon_radius:
		current_balloon.queue_free()
		DialogueManager.dialogue_ended.emit(current_dialogue_resource)
		current_balloon = null
		current_dialogue_resource = null
		canceled_dialogue_by_distance = true

func interact(player_node):
	player = player_node
	var current_heart_level = DataManager.get_heart_level(npc_id)
	current_dialogue_resource = npc_data.get_dialogue_to_play(current_heart_level)
	
	if not current_dialogue_resource:
		return

	var titles = current_dialogue_resource.get_titles()
	var title = "start"+str(current_title_idx)
	
	if titles.has(title):
		current_balloon = DialogueManager.show_dialogue_balloon(current_dialogue_resource,title)
	
	canceled_dialogue_by_distance = false

func on_dialogue_end(dialogue_resource : DialogueResource):
	if dialogue_resource == current_dialogue_resource and not canceled_dialogue_by_distance:
		current_title_idx += 1
		
		if not current_dialogue_resource:
			return
			
		var titles = current_dialogue_resource.get_titles()
		var next_title_key = "start" + str(current_title_idx)
		
		if not titles.has(next_title_key):
			if loop_titles:
				current_title_idx = 0
