extends CharacterBody2D

var playerAlive = true
var invulnerable = false
var playerHealth: int = 5;
const speed = 300.0

signal playerDeath
signal restart

func _ready():
	$BackgroundColor.modulate = Color(0,0,0,0)
	$HUD/GameOverLabel.hide()
	$HUD/RetryButton.hide()
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	if playerAlive:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		
		if !Input.is_anything_pressed():
			$AnimatedSprite2D.play("idle");
			velocity.x = 0
			velocity.y = 0
		else:
			if Input.is_action_pressed("right"):
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("walk_sideways")
			
			elif Input.is_action_pressed("left"):
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("walk_sideways")
		
			if Input.is_action_pressed("up"):
				velocity.y = -speed
				$AnimatedSprite2D.play("walk_back")
			elif Input.is_action_pressed("down"):
				velocity.y = speed
				$AnimatedSprite2D.play("idle")
			
			velocity.x = direction * speed
	
		for detector in $EnemyCollisionDetectors.get_children():
				# Needed the "(detector.get_collider() != null)" or else it crashes after deleting the collider
				if detector.is_colliding() and (detector.get_collider() != null) && playerAlive:
					var collider = detector.get_collider()
					if collider.is_in_group("enemy"):
						# If not attacking
						if !invulnerable:
							playerDamaged(collider, delta)

		move_and_slide()
	
func playerDamaged(enemy, delta):
	# Damage
	playerHealth -= 1
	invulnerable = true
	knockback(enemy, delta)
	
	if (playerHealth > 0):
		# Turns player opacity to 0.5
		modulate.a = 0.5
		$InvincibilityTimer.start()
	
	else:
		$BackgroundColor.modulate = Color(0,0,0,1)
		playerAlive = false
		velocity.x = 0
		velocity.y = 0
		$HUD/GameOverLabel.show()
		$HUD/RetryButton.show()
		playerDeath.emit()
	
	
func knockback(enemy, delta):
	var xVel
	var yVel
	# Collide on the left
	if enemy.global_position.x < global_position.x:
		xVel = speed * 500 * delta
	# Collide on the right
	else:
		xVel = speed * -500 * delta
	
	# Collide from the top
	if enemy.global_position.y < global_position.y:
		yVel = speed * 500 * delta
	# Collide from the bottom
	else:
		yVel = speed * -500 * delta
	
	velocity = Vector2(xVel, yVel)

## Detects when the timer for the invincibility frames ends
func _on_invincibility_timer_timeout() -> void:
	# Sets player model back to opaque
	modulate.a = 1
	invulnerable = false
	print("playerHealth = ", playerHealth)
	# Sets the animation of the health bar
	#detectPlayerHealth()


func _on_retry_button_pressed() -> void:
	restart.emit()
