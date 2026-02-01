extends CharacterBody2D

var playerAlive = true
var invulnerable = false
var invisible
var invisBarCharge: int = 100
var invisTimerRunning = false
var isAttacking = false
var playerHealth: int = 5;

var speed = 300.0
var direction

var maskNum
var armaMask = false
var bearMask = false
var fishMask = false

var armaAbility = false
var bearAbility = false
var fishAbility = false

var bearCharge: int = 100
var bearTimerRunning = false

var justShot = false

var dash = false
var dashCooldown = false

signal shoot
signal playerDeath
signal restart

func _ready():
	invisible = false
	maskNum = 0
	$BackgroundColor.modulate = Color(0,0,0,0)
	$Attack.hide()
	$HUD/GameOverLabel.hide()
	$HUD/RetryButton.hide()
	$HUD/BearAbilityBackground.hide()
	$HUD/BearAbility.hide()
	$HUD/Masks/FirstMaskSprite.play("idle")
	$HUD/Masks/SecondMaskSprite.play("idle")
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
		direction = Input.get_axis("left", "right")
		
		if !Input.is_anything_pressed():
			if !dash:
				$AnimatedSprite2D.play("idle");
				velocity.x = 0
				velocity.y = 0
		else:
			if Input.is_action_pressed("right") and !dash:
				$AnimatedSprite2D.flip_h = true
				#$Attack.flip_h = not $Attack.flip_h
				#$AttackDetector.scale.x *= -1
				$AttackDetector.look_at(Vector2(position.x - 50, position.y))
				$AttackDetector.scale.x = 1
				#$AnimatedSprite2D.play("walk_sideways")
			
			elif Input.is_action_pressed("left") and !dash:
				$AnimatedSprite2D.flip_h = false
				#$Attack.flip_h = not $Attack.flip_h
				$AttackDetector.rotation = 0
				$AttackDetector.scale.x = 1
				#$AnimatedSprite2D.play("walk_sideways")
		
			if Input.is_action_pressed("up"):
				velocity.y = -speed
				$AttackDetector.look_at(Vector2(position.x, position.y + 50))
				$AttackDetector.scale.x = 1.5
				#$AnimatedSprite2D.play("walk_back")
			elif Input.is_action_pressed("down"):
				velocity.y = speed
				$AttackDetector.look_at(Vector2(position.x, position.y - 50))
				$AttackDetector.scale.x = 1.5
				$AnimatedSprite2D.play("idle")
			else:
				velocity.y = 0
			
			velocity.x = direction * speed
			
			if dash:
				if velocity.y < 0:
					velocity.y = -speed
				elif velocity.y > 0:
					velocity.y = speed
		
		# Drop masks
		if Input.is_action_just_pressed("swapMask") and (maskNum > 0) and !bearAbility:
			swapMask()
		if Input.is_action_just_pressed("dropMask") and (maskNum > 0) and !bearAbility:
			dropMask()
		if Input.is_action_just_pressed("ability") and bearCharge == 100:
			abilityCheck()
			
		# Bear Ability Stuff	
		if bearAbility:
			if !bearTimerRunning:
				bearTimerRunning = true
				$BearTimer.start()
		else:
			if bearCharge < 100 and !bearTimerRunning:
				bearTimerRunning = true
				$BearTimer.start()
		
		
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
			
			
			
		# Attack
		if Input.is_action_just_pressed("attack") and !dash:
			# Can't stay invisible while attacking
			if invisible:
				invisible = false
				$AnimatedSprite2D.modulate.a = 1
				invisTimerRunning = false
				$InvisTimer.stop()
			# The fish shoots projectiles, so we will not go melee while it is equipped
			if !fishAbility and !armaAbility:
				$Attack.show()
				$AttackTimer.start()
				if $AttackDetector.is_colliding() and ($AttackDetector.get_collider() != null) and !isAttacking:
					isAttacking = true
					var collider = $AttackDetector.get_collider()
					if collider.is_in_group("enemy"):
						if(bearAbility):
							collider.isDamaged("bear")
						else:
							collider.isDamaged("normal")
			elif fishAbility:
				if !justShot:
					print("Shooting a bullet now...")
					justShot = true
					shoot.emit()
					$ShootTimer.start()
			# Armadillo Ability Stuff
			if armaAbility:
				if !dash and !dashCooldown:
					dash = true
					dashCooldown = true
					speed = 1200.0
					$DashTimer.start()
				
				
		# Damage
		for detector in $EnemyCollisionDetectors.get_children():
				# Needed the "(detector.get_collider() != null)" or else it crashes after deleting the collider
				if detector.is_colliding() and (detector.get_collider() != null) and playerAlive and !bearAbility and !dash:
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
		$AnimatedSprite2D.modulate.a = 0.5
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

func getMask(maskName):
	#if (maskNum == 0):
	$HUD/Masks/FirstMaskSprite.show()
	$HUD/Masks/SecondMaskSprite.show()
	if $HUD/Masks/FirstMaskSprite.animation == "idle":
		if maskName == "armadillo":
			$HUD/Masks/FirstMaskSprite.play("armadillo")
		elif maskName == "bear":
			$HUD/Masks/FirstMaskSprite.play("bear")
		elif maskName == "fish":
			print("Fish mask")
			$HUD/Masks/FirstMaskSprite.play("fish")
	elif $HUD/Masks/SecondMaskSprite.animation == "idle":
		if maskName == "armadillo":
			print("Fish mask")
			$HUD/Masks/SecondMaskSprite.play("armadillo")
		elif maskName == "bear":
			$HUD/Masks/SecondMaskSprite.play("bear")
		elif maskName == "fish":
			$HUD/Masks/SecondMaskSprite.play("fish")
				

func swapMask():
	armaAbility = false
	bearAbility = false
	fishAbility = false
	$HUD/Masks/FirstMask.color = Color("White")
	
	if $HUD/Masks/SecondMaskSprite.animation == "idle":
		if armaMask:
			$HUD/Masks/SecondMaskSprite.play("armadillo")
		elif bearMask:
			$HUD/Masks/SecondMaskSprite.play("bear")
		elif fishMask:
			$HUD/Masks/SecondMaskSprite.play("fish")
		$HUD/Masks/FirstMaskSprite.play("idle")
	elif $HUD/Masks/FirstMaskSprite.animation == "idle":
		if armaMask:
			$HUD/Masks/FirstMaskSprite.play("armadillo")
		elif bearMask:
			$HUD/Masks/FirstMaskSprite.play("bear")
		elif fishMask:
			$HUD/Masks/FirstMaskSprite.play("fish")
		$HUD/Masks/SecondMaskSprite.play("idle")
	elif $HUD/Masks/FirstMaskSprite.animation == "armadillo":
		if bearMask:
			$HUD/Masks/FirstMaskSprite.play("bear")
		elif fishMask:
			$HUD/Masks/FirstMaskSprite.play("fish")
		$HUD/Masks/SecondMaskSprite.play("armadillo")
	elif $HUD/Masks/FirstMaskSprite.animation == "bear":
		if armaMask:
			$HUD/Masks/FirstMaskSprite.play("armadillo")
		elif fishMask:
			$HUD/Masks/FirstMaskSprite.play("fish")
		$HUD/Masks/SecondMaskSprite.play("bear")
	elif $HUD/Masks/FirstMaskSprite.animation == "fish":
		if armaMask:
			$HUD/Masks/FirstMaskSprite.play("armadillo")
		elif bearMask:
			$HUD/Masks/FirstMaskSprite.play("bear")
		$HUD/Masks/SecondMaskSprite.play("fish")
		
		
func dropMask():
	if $HUD/Masks/SecondMaskSprite.animation != "idle":
		if $HUD/Masks/SecondMaskSprite.animation == "armadillo":
			$HUD/Masks/SecondMaskSprite.play("idle")
			if $HUD/Masks/FirstMaskSprite.animation != "armadillo":
				armaMask = false
		elif $HUD/Masks/SecondMaskSprite.animation == "bear":
			$HUD/Masks/SecondMaskSprite.play("idle")
			if $HUD/Masks/FirstMaskSprite.animation != "bear":
				bearMask = false
		elif $HUD/Masks/SecondMaskSprite.animation == "fish":
			$HUD/Masks/SecondMaskSprite.play("idle")
			if $HUD/Masks/FirstMaskSprite.animation != "fish":
				fishMask = false
	elif $HUD/Masks/FirstMaskSprite.animation != "idle":
		$HUD/Masks/FirstMask.color = Color("White")
		if $HUD/Masks/FirstMaskSprite.animation == "armadillo":
			$HUD/Masks/FirstMaskSprite.play("idle")
			if $HUD/Masks/SecondMaskSprite.animation != "armadillo":
				armaMask = false
			armaAbility = false
		elif $HUD/Masks/FirstMaskSprite.animation == "bear":
			$HUD/Masks/FirstMaskSprite.play("idle")
			if $HUD/Masks/SecondMaskSprite.animation != "bear":
				bearMask = false
			bearAbility = false
		elif $HUD/Masks/FirstMaskSprite.animation == "fish":
			$HUD/Masks/FirstMaskSprite.play("idle")
			if $HUD/Masks/SecondMaskSprite.animation != "fish":
				fishMask = false
			fishAbility = false
	maskNum -= 1
	
	
	
func abilityCheck():
	if $HUD/Masks/FirstMaskSprite.animation == "armadillo":
		armaAbility = true
		$HUD/Masks/FirstMask.color = Color("Pink")
	elif $HUD/Masks/FirstMaskSprite.animation == "bear":
		bearAbility = true
		$HUD/Masks/FirstMask.color = Color("Goldenrod")
	elif $HUD/Masks/FirstMaskSprite.animation == "fish":
		fishAbility = true
		$HUD/Masks/FirstMask.color = Color("Royal_Blue")

## Detects when the timer for the invincibility frames ends
func _on_invincibility_timer_timeout() -> void:
	# Sets player model back to opaque
	$AnimatedSprite2D.modulate.a = 1
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
		


func _on_bear_timer_timeout() -> void:
	bearTimerRunning = false
	if (bearAbility):
		$HUD/BearAbilityBackground.show()
		$HUD/BearAbility.show()
		if bearCharge > 0:
			bearCharge -= 1
			$HUD/BearAbility.size.x -= 3
		else:
			$HUD/BearAbilityBackground.hide()
			$HUD/BearAbility.hide()
			$HUD/Masks/FirstMaskSprite.play("idle")
			$HUD/Masks/FirstMask.color = Color(255, 255, 255)
			maskNum -= 1
			if $HUD/Masks/SecondMaskSprite.animation != "bear":
				bearMask = false
			bearAbility = false
	else:
		bearCharge += 1
		$HUD/BearAbility.size.x += 3


func _on_shoot_timer_timeout() -> void:
	justShot = false


func _on_dash_timer_timeout() -> void:
	dash = false
	speed = 300.0
	velocity.x = 0
	velocity.y = 0
	$DashCooldownTimer.start()


func _on_dash_cooldown_timer_timeout() -> void:
	dashCooldown = false
