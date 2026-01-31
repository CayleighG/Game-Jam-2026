extends Node2D

@onready var arma_mask = preload("res://Scenes/Masks/armadillo_mask.tscn")
@onready var bear_mask = preload("res://Scenes/Masks/bear_mask.tscn")
@onready var fish_mask = preload("res://Scenes/Masks/fish_mask.tscn")
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

func _on_arma_mask_obtained(mask) -> void:
	if ($Player.maskNum < 2):
		print("Armadillo Mask Obtained!")
		$Player.armaMask = true
		$Player.getMask("armadillo")
		$Player.maskNum += 1
		mask.queue_free()


func _on_tank_enemy_tank_defeat(enemyPosition) -> void:
	print("Mask dropped")
	var mask = bear_mask.instantiate()
	get_tree().get_root().add_child(mask)
	mask.global_position = enemyPosition
	mask.bearMaskObtained.connect(_on_bear_mask_obtained)
	
func _on_bear_mask_obtained(mask) -> void:
	if ($Player.maskNum < 2):
		print("Bear Mask Obtained!")
		$Player.bearMask = true
		$Player.getMask("bear")
		$Player.maskNum += 1
		mask.queue_free()


func _on_sniper_enemy_sniper_defeat(enemyPosition) -> void:
	print("Mask dropped")
	var mask = fish_mask.instantiate()
	get_tree().get_root().add_child(mask)
	mask.global_position = enemyPosition
	mask.fishMaskObtained.connect(_on_fish_mask_obtained)
	
func _on_fish_mask_obtained(mask) -> void:
	if ($Player.maskNum < 2):
		print("Fish Mask Obtained!")
		$Player.fishMask = true
		$Player.getMask("fish")
		$Player.maskNum += 1
		mask.queue_free()
