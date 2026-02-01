extends Node2D

@onready var arma_mask = preload("res://Scenes/Masks/armadillo_mask.tscn")
@onready var bear_mask = preload("res://Scenes/Masks/bear_mask.tscn")
@onready var fish_mask = preload("res://Scenes/Masks/fish_mask.tscn")
@onready var enemy_bullets = preload("res://Scenes/Enemies/enemy_bullet.tscn")
@onready var player_bullets = preload("res://Scenes/player_bullet.tscn")
@onready var first_aid = preload("res://Scenes/first_aid.tscn")

var enemyStop = false
var enemyCount

var door1Open = false
var door2Open = false
var door3Open = false
var door4Open = false
var door5Open = false
var door6Open = false
var door7Open = false
var door8Open = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemyCount = 0
	var enemies = get_tree().get_nodes_in_group("enemy")
	for n in enemies:
		enemyCount += 1
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	checkEnemies()


func _on_player_death() -> void:
	enemyStop = true
	var enemies = get_tree().get_nodes_in_group("enemy")
	for n in enemies:
		if n.has_method("player_death"):
			n.player_death()
	var masks = get_tree().get_nodes_in_group("mask")
	for n in masks:
		n.queue_free()
	var bullets = get_tree().get_nodes_in_group("bullet")
	for n in bullets:
		n.queue_free()
	var healthKits = get_tree().get_nodes_in_group("health_kit")
	for n in healthKits:
		n.queue_free()


func _on_restart() -> void:
	get_tree().reload_current_scene()


func _on_enemy_defeat(enemyPosition) -> void:
	print("Health kit dropped")
	var healthKit = first_aid.instantiate()
	get_tree().get_root().add_child(healthKit)
	healthKit.add_to_group("health_kit")
	healthKit.global_position = enemyPosition
	healthKit.firstAidObtained.connect(_on_first_aid_obtained)

func _on_first_aid_obtained(healthKit) -> void:
	if ($Player.playerHealth < 5):
		print("Health Kit Obtained!")
		$Player.playerHealth += 1
		$Player.checkHealthBar()
		healthKit.queue_free()
	

func _on_rolling_enemy_roller_defeat(enemyPosition) -> void:
	print("Mask dropped")
	var mask = arma_mask.instantiate()
	get_tree().get_root().add_child(mask)
	mask.add_to_group("mask")
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
	mask.add_to_group("mask")
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
	mask.add_to_group("mask")
	mask.global_position = enemyPosition
	mask.fishMaskObtained.connect(_on_fish_mask_obtained)
	
func _on_fish_mask_obtained(mask) -> void:
	if ($Player.maskNum < 2):
		print("Fish Mask Obtained!")
		$Player.fishMask = true
		$Player.getMask("fish")
		$Player.maskNum += 1
		mask.queue_free()


func _on_player_shoot() -> void:
	if !enemyStop:
		print("Shot a bullet")
		var bullet = player_bullets.instantiate()
		get_tree().get_root().add_child(bullet)
		bullet.add_to_group("bullet")
		bullet.global_position = $Player.global_position
		#bullet.direction = (get_global_mouse_position() - global_position).normalized()
		bullet.flight()


func _on_sniper_enemy_sniper_fire(enemyPosition) -> void:
	if !enemyStop:
		print("Enemy shot a bullet")
		var bullet = enemy_bullets.instantiate()
		get_tree().get_root().add_child(bullet)
		bullet.add_to_group("bullet")
		bullet.global_position = enemyPosition
		bullet.flight($Player.position)
		
# This function deletes doors if specific requirements have been met
func checkEnemies():
	enemyCount -= 1
	if !door1Open and !is_instance_valid($Enemy1) and is_instance_valid($Doors/Door1):
		door1Open = true
		$Doors/Door1.queue_free()
	elif !door2Open and !is_instance_valid($rolling_enemy) and is_instance_valid($Doors/Door2):
		door2Open = true
		$Doors/Door2.queue_free()
	elif !door3Open and !is_instance_valid($rolling_enemy2) and !is_instance_valid($Enemy2) and is_instance_valid($Doors/Door3):
		door3Open = true
		$Doors/Door3.queue_free()
	elif !door4Open and !is_instance_valid($Enemy3) and !is_instance_valid($Enemy4) and !is_instance_valid($TankEnemy2) and !is_instance_valid($SniperEnemy4) and is_instance_valid($Doors/Door4):
		door4Open = true
		$Doors/Door4.queue_free()
	elif !door5Open and !is_instance_valid($Enemy5) and !is_instance_valid($rolling_enemy3) and !is_instance_valid($TankEnemy) and !is_instance_valid($Doors/Door4) and is_instance_valid($Doors/Door5):
		door5Open = true
		$Doors/Door5.queue_free()
	elif !door6Open and !is_instance_valid($SniperEnemy) and !is_instance_valid($SniperEnemy2) and !is_instance_valid($SniperEnemy5) and is_instance_valid($Doors/Door6):
		door6Open = true
		$Doors/Door6.queue_free()
	elif !door7Open and !is_instance_valid($rolling_enemy4) and is_instance_valid($Doors/Door7):
		door7Open = true
		$Doors/Door7.queue_free()
		
	if !door8Open and (enemyCount == 0) and is_instance_valid($Doors/Door8):
		door8Open = true
		$Doors/Door8.queue_free()
