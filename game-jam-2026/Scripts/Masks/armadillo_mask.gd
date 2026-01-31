extends CharacterBody2D

signal armaMaskObtained

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for detector in $Collision.get_children():
		# Needed the "(detector.get_collider() != null)" or else it crashes after deleting the collider
		if detector.is_colliding() and (detector.get_collider() != null):
			armaMaskObtained.emit()
			queue_free()
