extends CharacterBody2D

var direction = -1
var pursuit = false
const speed = 50
var wait = false
var stop = false
var left
var right
var health

@onready var player = get_node("../Player")

func _ready():
	health = 100
	velocity.x = speed
	$AnimatedSprite2D.play("idle")
	$HealthBar.hide()
	$HealthBarBackground.hide()

func _physics_process(delta: float) -> void:
	if (!stop):
		# A bit more reliable than is_on_wall()
		# is_on_wall() will activate if the enemy runs into the player, which we do not want
		if $WallDetector.is_colliding():
			direction = direction * -1
			# Flip the sprite in whichever direction it is not currently facing
			#$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
			# Flip the WallDetector
			$WallDetector.scale.x *= -1
			# Flips the detectors in the enemy's view
			for detector in $View.get_children():
				detector.scale.x *= -1
	
		if direction == 1:
			velocity.x = speed
			$AnimatedSprite2D.flip_h = true
			if ($WallDetector.scale.x > 0):
					$WallDetector.scale.x *= -1
		else: 
			velocity.x = -speed
			$AnimatedSprite2D.flip_h = false
			if ($WallDetector.scale.x < 0):
					$WallDetector.scale.x *= -1
		
		
		# Combat
		# Timer where the player has time to get out of the enemy's view
		# Enemy will rush them if they are still in view when the timer ends
		for detector in $View.get_children():
			if detector.is_colliding() and (detector.get_collider() != null) and !wait and !player.invisible:
					wait = true
					$DetectTimer.start()
	
		if pursuit and !player.invisible:
			# Rotating the detectors so the player is always in the enemy's "view"
			for detector in $View.get_children():
				detector.rotation = 135;
			$View.look_at(Vector2(player.position.x, player.position.y))
		
			velocity = position.direction_to(player.position) * speed
			# Check which way the enemy should be facing
			if (velocity.x > 0):
				direction = 1
				if ($WallDetector.scale.x > 0):
					$WallDetector.scale.x *= -1
			else:
				direction = -1
				if ($WallDetector.scale.x < 0):
					$WallDetector.scale.x *= -1

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
	print("Done pursuing!")
	# Put detectors back
	for detector in $View.get_children():
			detector.rotation = 0;
	if direction == 1:
		velocity.x = speed
		$View.look_at(Vector2($View.global_position.x - 10, $View.global_position.y))
	else: 
		velocity.x = -speed
		$View.look_at(Vector2($View.global_position.x + 10, $View.global_position.y))


func _on_detect_timer_timeout() -> void:
	print("Starting the detect timer")
	wait = false
	for detector in $View.get_children():
		if detector.is_colliding() and (detector.get_collider() != null) and !player.invisible:
				pursuit = true
				$PursuitTimer.start()
				print("Now pursuing!")
				
