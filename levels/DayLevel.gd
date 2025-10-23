extends Node2D

@export var npcs : Array[NPCInstance]

func _ready() -> void:
	if npcs.size() > 0:
		for npc in npcs:
			if not DataManager.is_npc_alive(npc.npc_id):
				npc.queue_free()
			else:
				print("not dead")
				
		
		
