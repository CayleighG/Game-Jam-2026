extends CharacterBody2D

var direction = -1
const speed = 50

func _ready():
	velocity.x = speed
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	# A bit more reliable than is_on_wall()
	# is_on_wall() will activate if the enemy runs into the player, which we do not want
	if $WallDetector.is_colliding():
		direction = direction * -1
		# Flip the sprite in whichever direction it is not currently facing
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
		# Flips the WallDetector
		$WallDetector.scale.x *= -1
	
	if direction == 1:
		velocity.x = speed
	else: 
		velocity.x = -speed
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
