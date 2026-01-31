extends Node2D

@onready var arma_mask = preload("res://Scenes/armadillo_mask.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


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


func _on_rolling_enemy_roller_defeat(enemyPosition) -> void:
	print("Mask dropped")
	var mask = arma_mask.instantiate()
	get_tree().get_root().add_child(mask)
	mask.global_position = enemyPosition
	mask.armaMaskObtained.connect(_on_arma_mask_obtained)

func _on_arma_mask_obtained() -> void:
	print("Armadillo Mask Obtained!")
	$Player.armaMask = true
