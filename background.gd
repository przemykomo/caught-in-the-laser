extends Sprite2D

var speed: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = move_toward(speed, 1500, 800 * delta)
	position.x -= speed * delta
	if position.x < 0:
		position.x += 620
