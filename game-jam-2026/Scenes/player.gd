extends CharacterBody2D

var playerAlive = true;
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready():
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	
	if playerAlive:
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
				velocity.y = -SPEED
				$AnimatedSprite2D.play("walk_back")
			elif Input.is_action_pressed("down"):
				velocity.y = SPEED
				$AnimatedSprite2D.play("idle")
			
			velocity.x = direction * SPEED
	
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
