extends CharacterBody2D

var playerAlive = true
var invulnerable = false
var invisible
var invisBarCharge: int = 100
var invisTimerRunning = false
var isAttacking = false
var playerHealth: int = 5;
const speed = 300.0

signal playerDeath
signal restart

func _ready():
	invisible = false
	$BackgroundColor.modulate = Color(0,0,0,0)
	$Attack.hide()
	$HUD/GameOverLabel.hide()
	$HUD/RetryButton.hide()
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	# GET UNSTUCK
	if $GetUnstuck.is_colliding():
		print("STUCK!")
		if !$Unstuck/UnstuckDetector1.is_colliding():
			global_position.y -= 100
		elif !$Unstuck/UnstuckDetector2.is_colliding():
			global_position.y += 100
		elif !$Unstuck/UnstuckDetector3.is_colliding():
			global_position.x -= 200
		elif !$Unstuck/UnstuckDetector4.is_colliding():
			global_position.y += 100
		
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
				#$Attack.flip_h = not $Attack.flip_h
				#$AttackDetector.scale.x *= -1
				$AttackDetector.look_at(Vector2(position.x - 50, position.y))
				$AttackDetector.scale.x = 1
				$AnimatedSprite2D.play("walk_sideways")
			
			elif Input.is_action_pressed("left"):
				$AnimatedSprite2D.flip_h = false
				#$Attack.flip_h = not $Attack.flip_h
				$AttackDetector.rotation = 0
				$AttackDetector.scale.x = 1
				$AnimatedSprite2D.play("walk_sideways")
		
			if Input.is_action_pressed("up"):
				velocity.y = -speed
				$AttackDetector.look_at(Vector2(position.x, position.y + 50))
				$AttackDetector.scale.x = 1.5
				$AnimatedSprite2D.play("walk_back")
			elif Input.is_action_pressed("down"):
				velocity.y = speed
				$AttackDetector.look_at(Vector2(position.x, position.y - 50))
				$AttackDetector.scale.x = 1.5
				$AnimatedSprite2D.play("idle")
			else:
				velocity.y = 0
			
			velocity.x = direction * speed
		
		# Invisibility
		if Input.is_action_pressed("invisibility") and invisBarCharge == 100:
			if !invisible:
				print("Changinging invisibility to true")
				invisible = true
				$AnimatedSprite2D.modulate.a = 0.1
			
		if invisible:
			if !invisTimerRunning:
				invisTimerRunning = true
				$InvisTimer.start()
		else:
			if invisBarCharge < 100 and !invisTimerRunning:
				invisTimerRunning = true
				$InvisTimer.start()
			
		if Input.is_action_pressed("attack"):
			# Can't stay invisible while attacking
			if invisible:
				invisible = false
				$AnimatedSprite2D.modulate.a = 1
				invisTimerRunning = false
				$InvisTimer.stop()
			$Attack.show()
			$AttackTimer.start()
			if $AttackDetector.is_colliding() and ($AttackDetector.get_collider() != null) and !isAttacking:
				isAttacking = true
				var collider = $AttackDetector.get_collider()
				if collider.is_in_group("enemy"):
					collider.isDamaged()
					#print(collider.health)
				
	
		for detector in $EnemyCollisionDetectors.get_children():
				# Needed the "(detector.get_collider() != null)" or else it crashes after deleting the collider
				if detector.is_colliding() and (detector.get_collider() != null) && playerAlive:
					var collider = detector.get_collider()
					if collider.is_in_group("enemy"):
						# If not attacking
						if !invulnerable:
							playerDamaged(collider, delta)

		move_and_slide()
		
	elif playerAlive and playerDamaged:
		invisible = false
	
func playerDamaged(enemy, delta):
	# Damage
	if invisible:
		invisible = false
		$AnimatedSprite2D.modulate.a = 1
		invisTimerRunning = false
		$InvisTimer.stop()
	#playerHealth -= 1
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
		$HUD/InvisBar.hide()
		$HUD/InvisBarBackground.hide()
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


func _on_attack_timer_timeout() -> void:
	isAttacking = false
	$Attack.hide()


func _on_invis_timer_timeout() -> void:
	invisTimerRunning = false
	if invisible:
		if invisBarCharge > 0:
			#print(invisBarCharge)
			invisBarCharge -= 1;
			$HUD/InvisBar.size.x -= 3
		else:
			print("Not invisible")
			invisible = false
			$AnimatedSprite2D.modulate.a = 1
	else:
		invisBarCharge += 1
		$HUD/InvisBar.size.x += 3
		#print(invisBarCharge)
		
