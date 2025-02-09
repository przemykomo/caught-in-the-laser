extends Area2D

@export var bullet_scene: PackedScene
var can_attack: bool = false
var just_started: bool = true
var health: int = 1000
var score: int = 0
var dead: bool = false

func _input(event):
	if can_attack && !dead && event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		var velocity = global_position.direction_to(event.position)
		var bullet = bullet_scene.instantiate()
		bullet.velocity = velocity.normalized() * 500
		bullet.position = position
		bullet.rotation = velocity.angle()
		get_parent().add_child(bullet)
		can_attack = false
		$Ufo.frame = 1
		$Cooldown.start()
		$LaserShootSound.play()

func _physics_process(delta: float) -> void:
	if just_started:
		position.x += 300 * delta
		if position.x >= 310:
			just_started = false
			can_attack = true
			%PlaneSpawner.start()
	var velocity = Input.get_vector("left", "right", "top", "down")
	position += velocity * 100 * delta
	position = position.clamp(Vector2(20, 20), Vector2(600, 460))
	
	if has_overlapping_areas():
		health -= int(100 * delta)
		if health < 0 && !dead:
			dead = true
			$Explosion.play()
			$ExplosionSound.play()
			$Ufo.visible = false
	$Ufo.modulate.g = health / 2000.0 + 0.5
	$Ufo.modulate.b = health / 2000.0 + 0.5
	$Ufo.position.x = (1000 - health) / 500.0 * sin(Time.get_ticks_msec() / 100.0)
	$Ufo.position.y = (1000 - health) / 500.0 * sin(Time.get_ticks_msec() / 100.0 + 1)

func _on_cooldown_timeout() -> void:
	can_attack = true
	$Ufo.frame = 0

func _on_explosion_animation_finished() -> void:
	%DeathScreen.visible = true
	%DeathScreen/Score.text = "Score: " + str(score)
	get_parent().process_mode = PROCESS_MODE_DISABLED
