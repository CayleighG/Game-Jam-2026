extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$Player.playerDeath.connect(_on_player_death)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_death() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	for n in enemies:
		if n.has_method("player_death"):
			n.player_death()


func _on_restart() -> void:
	get_tree().reload_current_scene()
