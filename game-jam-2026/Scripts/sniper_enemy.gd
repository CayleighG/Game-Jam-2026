extends CharacterBody2D

var direction = -1
var pursuit = false
const speed = 80
var wait = false
var stop = false
var firing = false
var wallRun = false
var left
var right
var health

@onready var player = get_node("../Player")
@onready var bullets = preload("res://Scenes/enemy_bullet.tscn")

func _ready():
	health = 100
	#velocity.x = speed
	$AnimatedSprite2D.play("idle")
	$HealthBar.hide()
	$HealthBarBackground.hide()
	$Alert.hide()

func _physics_process(delta: float) -> void:
	if (!stop):
		# Combat
		# Timer where the player has time to get out of the enemy's view
		# Enemy will rush them if they are still in view when the timer ends
		for detector in $View.get_children():
			if detector.is_colliding() and (detector.get_collider() != null) and !wait and !player.invisible:
					wait = true
					$DetectTimer.start()
	
		# Snipers are interesting. Once they spot the player, they never lose aggro until defeated
		# The player can sneak away when invisible, but the sniper always knows where they once the player decloaks.
		if pursuit and !player.invisible:
			# A bit more reliable than is_on_wall()
			# is_on_wall() will activate if the enemy runs into the player, which we do not want
			if $WallDetector.is_colliding() or $WallDetector2.is_colliding():
				direction = direction * -1
				# Flip the WallDetector
				#$WallDetector.scale.x *= -1
				# Flips the detectors in the enemy's view
				for detector in $View.get_children():
					detector.scale.x *= -1
				
			if $TopandBottomDetector.is_colliding():
				if velocity.y < 0:
					velocity.y = speed
				else:
					velocity.y = -speed
				$TopandBottomDetector.scale.y *= -1
	
			if direction == 1:
				velocity.x = speed
				$AnimatedSprite2D.flip_h = true
				#if ($WallDetector.scale.x > 0):
					#$WallDetector.scale.x *= -1
			else: 
				velocity.x = -speed
				$AnimatedSprite2D.flip_h = false
				#if ($WallDetector.scale.x < 0):
					#$WallDetector.scale.x *= -1
					
					
			# Rotating the detectors so the player is always in the enemy's "view"
			#for detector in $View.get_children():
				#detector.rotation = 135;
			$View.look_at(Vector2(player.position.x, player.position.y))
		
			# Have sniper move away once the player gets too close
			if !$WallDetector.is_colliding() or $WallDetector2.is_colliding():
				var distance = global_position.distance_to(player.global_position)
				if distance < 400:
					velocity = -position.direction_to(player.position) * speed
				elif distance < 600:
					# This top velocity thing is to get the sniper to face the correct direction
					velocity = position.direction_to(player.position) * speed
					velocity.x = 0
					velocity.y = 0
					if !firing:
						firing = true
						$FireTimer.start()
				else:
					velocity = position.direction_to(player.position) * speed
				# Check which way the enemy should be facing
				if (velocity.x > 0):
					direction = 1
					#if ($WallDetector.scale.x > 0):
						#$WallDetector.scale.x *= -1
				else:
					direction = -1
					#if ($WallDetector.scale.x < 0):
						#$WallDetector.scale.x *= -1
			else:
				pursuit = false
				$WallRunTimer.start()
				if direction == 1:
					velocity.x = speed
					$AnimatedSprite2D.flip_h = true
					#if ($WallDetector.scale.x > 0):
						#$WallDetector.scale.x *= -1
				else: 
					velocity.x = -speed
					$AnimatedSprite2D.flip_h = false
					#if ($WallDetector.scale.x < 0):
						#$WallDetector.scale.x *= -1
		#elif player.invisible:
			#velocity.x = 0
			#velocity.y = 0

		move_and_slide()

func player_death():
	stop = true
	$AnimatedSprite2D.stop()
	
func isDamaged():
	health -= 25
	print("Enemy Health: ", health)
	$HealthBar.show()
	$HealthBarBackground.show()
	if $HealthBar.size.x > 0:
		$HealthBar.size.x -= 30
	if health == 0:
		print("Deleting enemy")
		queue_free()

func _on_pursuit_timer_timeout() -> void:
	pursuit = false
	$Alert.hide()
	print("Done pursuing!")
	# Put detectors back
	for detector in $View.get_children():
		detector.rotation = 0;
	if direction == 1:
		velocity.x = speed
		$View.look_at(Vector2($View.global_position.x + 10, $View.global_position.y))
	else: 
		velocity.x = -speed
		$View.look_at(Vector2($View.global_position.x - 10, $View.global_position.y))


func _on_detect_timer_timeout() -> void:
	print("Starting the detect timer")
	wait = false
	for detector in $View.get_children():
		if detector.is_colliding() and (detector.get_collider() != null) and !player.invisible:
			$Alert.show()
			pursuit = true
			$PursuitTimer.start()
			print("Now pursuing!")
	if pursuit:
		for detector in $View.get_children():
			if detector.scale.x > 0:
				detector.scale.x *= -1
				


func _on_fire_timer_timeout() -> void:
	print("Shot a bullet")
	var bullet = bullets.instantiate()
	get_tree().get_root().add_child(bullet)
	bullet.global_position = global_position
	bullet.flight(player.position)
	firing = false


func _on_wall_run_timer_timeout() -> void:
	pursuit = true
