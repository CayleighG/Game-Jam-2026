extends CharacterBody2D

var direction = -1
var pursuit = false
const speed = 50
var wait = false
var stop = false
var dashAttack = false
var dashCooldown = false
var left
var right
var health

signal rollerDefeat(Vector2)
signal enemyDeath

@onready var player = get_node("../Player")

func _ready():
	health = 100
	velocity.x = speed
	$AnimatedSprite2D.play("idle")
	$HealthBar.hide()
	$HealthBarBackground.hide()
	$Alert.hide()

func _physics_process(delta: float) -> void:
	if (!stop):
		# A bit more reliable than is_on_wall()
		# is_on_wall() will activate if the enemy runs into the player, which we do not want
		if $WallDetector.is_colliding():
			direction = direction * -1
			# Flip the WallDetector
			$WallDetector.scale.x *= -1
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
			#$View.look_at(Vector2($View.global_position.x - 10, $View.global_position.y))
			if ($WallDetector.scale.x > 0):
				$WallDetector.scale.x *= -1
		else: 
			velocity.x = -speed
			$AnimatedSprite2D.flip_h = false
			#$View.look_at(Vector2($View.global_position.x + 10, $View.global_position.y))
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
		
			# Check how far away the player is
			if dashCooldown:
				velocity.x = 0
				velocity.y = 0
			else:
				var distance = global_position.distance_to(player.global_position)
				#print(distance)
				# If the player is not within attacking range
				if distance > 400 and !dashAttack:
					$AnimatedSprite2D.scale.x = 0.4
					$AnimatedSprite2D.scale.y = 0.4
					$AnimatedSprite2D.play("idle")
					velocity = position.direction_to(player.global_position) * speed
				else:
					$AnimatedSprite2D.scale.x = 1
					$AnimatedSprite2D.scale.y = 1
					$AnimatedSprite2D.play("attack")
					if !dashAttack:
						dashAttack = true
						$DashTimer.start()
						#var dir = (player.position - position).normalized()
						velocity = position.direction_to(player.global_position) * (speed * 10)
						#velocity *= 10
						#velocity = position.direction_to(player.position) * (speed * 10)
			
				# Check which way the enemy should be facing
				if (velocity.x > 0):
					direction = 1
					if ($WallDetector.scale.x > 0):
						$WallDetector.scale.x *= -1
				else:
					direction = -1
					if ($WallDetector.scale.x < 0):
						$WallDetector.scale.x *= -1
		elif player.invisible:
			$DashTimer.stop()
			$AnimatedSprite2D.scale.x = 0.4
			$AnimatedSprite2D.scale.y = 0.4
			$AnimatedSprite2D.play("idle")
			dashCooldown = false
			dashAttack = false

		move_and_slide()

func player_death():
	stop = true
	$AnimatedSprite2D.stop()
	
func isDamaged(type):
	if type == "normal":
		health -= 25
		if $HealthBar.size.x > 0:
			$HealthBar.size.x -= 30
	elif type == "bear":
		health -= 50
		if $HealthBar.size.x > 0:
			$HealthBar.size.x -= 60
	elif type == "fish":
		health -= 12.5
		if $HealthBar.size.x > 0:
			$HealthBar.size.x -= 15
	print("Enemy Health: ", health)
	$HealthBar.show()
	$HealthBarBackground.show()
	if health <= 0:
		print("Deleting enemy")
		rollerDefeat.emit(self.global_position)
		enemyDeath.emit()
		queue_free()
	else:
		pursuit = true

func _on_pursuit_timer_timeout() -> void:
	pursuit = false
	$Alert.hide()
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
			$Alert.show()
			pursuit = true
			$PursuitTimer.start()
			print("Now pursuing!")
	if pursuit:
		for detector in $View.get_children():
			if detector.scale.x < 0:
				detector.scale.x *= -1


func _on_dash_timer_timeout() -> void:
	dashAttack = false
	if !dashCooldown:
		dashCooldown = true
		$AnimatedSprite2D.scale.x = 0.4
		$AnimatedSprite2D.scale.y = 0.4
		$AnimatedSprite2D.play("idle")
		$DashTimer.start()
	else:
		dashCooldown = false
