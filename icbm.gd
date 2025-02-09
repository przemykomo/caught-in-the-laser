extends Area2D

var player: Area2D
var exploded: bool = false
var velocity: Vector2
var is_dumb: bool = false

func _ready() -> void:
	if is_dumb:
		velocity = position.direction_to(player.position) * 3
		$AnimatedSprite2D.rotation = velocity.angle() + PI / 2
		$Despawn.start()

func _physics_process(delta: float) -> void:
	if !exploded:
		if !is_dumb:
			var direction = position.direction_to(player.position)
			velocity = direction - direction.orthogonal() * 5
			$AnimatedSprite2D.rotation = direction.angle() + PI
		position += velocity * 100 * delta

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if !exploded:
		$ExplosionSound.play()
		$AnimatedSprite2D.play("explosion")
		$AnimatedSprite2D.scale = Vector2(4, 4)
		$AnimatedSprite2D.rotation = 0
		if area == player:
			player.health -= 250
			#player.position += 4 * position.direction_to(player.position)
			exploded = true

func _on_despawn_timeout() -> void:
	queue_free()
