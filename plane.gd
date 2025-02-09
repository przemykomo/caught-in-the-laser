extends Area2D

var velocity: Vector2
var net_connected: bool = false
var ready_for_net: bool = false
var player
var net
var dead: bool = false
var removed_from_net: bool = false

func _physics_process(delta: float) -> void:
	
	var target_pos: Vector2 = player.position + 150 * player.position.direction_to(position)
	var target_velocity = position.direction_to(target_pos) * 0.07 * (position - target_pos).length()
	
	for plane in get_tree().get_nodes_in_group("planes"):
		if plane != self:
			var dir = plane.position.direction_to(position)
			target_velocity += dir * 100 / (position - plane.position).length()

	target_velocity += position.direction_to(player.position).orthogonal() * 0.2
	target_velocity = target_velocity.clamp(Vector2(-1, -1), Vector2(1, 1))
	if $Explosion.is_playing():
		$Plane.position.x = sin(Time.get_ticks_msec())
		$Plane.position.y = sin(Time.get_ticks_msec() + 1)
	if removed_from_net:
		target_velocity.x = -4
	velocity = velocity.move_toward(target_velocity, 5 * delta)
	position += velocity * 100 * delta
	
	if dead && position.x < -50:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	$Plane.modulate = Color(0.9, 0.9, 0.9)
	area.queue_free()
	if !$Explosion.is_playing():
		$Explosion.play()
		$ExplosionSound.play()
		$RemoveFromNet.start()

func _on_explosion_animation_finished() -> void:
	dead = true
	player.score += 1

func _on_ready_timer_timeout() -> void:
	ready_for_net = true

func _on_remove_from_net_timeout() -> void:
	var vertices: PackedVector2Array = net.polygon
	var my_index = -1
	for i in range(net.planes.size()):
		if net.planes[i] == self:
			my_index = i
		elif net.planes.size() <= 3:
			net.planes[i].net_connected = false
			net.planes[i].ready_for_net = false
	
	if my_index > -1:
		net.planes.remove_at(my_index)
		vertices.remove_at(my_index)
	
	if net.planes.size() < 3:
		net.planes.clear()
		vertices.clear()
	net.set_polygon(vertices)
	removed_from_net = true
	set_collision_layer_value(3, false)
	set_collision_mask_value(2, false)
