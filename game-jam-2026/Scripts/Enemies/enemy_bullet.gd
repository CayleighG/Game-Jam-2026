extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	for detector in $Collision.get_children():
		if detector.is_colliding() and (detector.get_collider() != null):
			var collider = detector.get_collider()
			if collider.is_in_group("player"):
				collider.playerDamaged(self, delta)
				queue_free()
	move_and_slide()

func flight(playerPosition):
	velocity = position.direction_to(playerPosition) * SPEED


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Bullet destroyed")
	queue_free()
