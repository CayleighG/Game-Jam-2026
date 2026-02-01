extends CharacterBody2D


const speed = 500.0
var direction = Vector2(0,0)
var _delta

func _physics_process(delta: float) -> void:
	for detector in $Collision.get_children():
		if detector.is_colliding() and (detector.get_collider() != null):
			var collider = detector.get_collider()
			if collider.is_in_group("enemy"):
				collider.isDamaged("fish")
				queue_free()
	move_and_slide()

func flight():
	direction = (get_global_mouse_position() - global_position).normalized()
	velocity = direction * speed


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Player bullet destroyed")
	queue_free()
