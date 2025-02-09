extends Polygon2D

var planes: Array[Area2D]
var entire_net_connected: bool = false

func _physics_process(delta: float) -> void:
	var vertices: PackedVector2Array = polygon
	if vertices.size() > 0 && planes.size() == vertices.size():
		texture_rotation -= 0.05 * delta
		var disconnected: bool = false
		for i in range(vertices.size()):
			if planes[i].net_connected:
				vertices[i] = planes[i].position
				if i < vertices.size() - 1 && !planes[i + 1].net_connected:
					var timer: Timer = planes[i + 1].get_node("ReadyTimer")
					if timer.is_stopped():
						timer.start()
			else:
				disconnected = true
				if planes[i].ready_for_net:
					vertices[i] = vertices[i].move_toward(planes[i].position, 500 * delta)
					if vertices[i] == planes[i].position:
						planes[i].net_connected = true
				else:
					vertices[i] = planes[0].position
		set_polygon(vertices)
		if !entire_net_connected && !disconnected:
			entire_net_connected = true
	$Line2D.points = polygon
	$Area2D/CollisionPolygon2D.polygon = polygon

func sort_clockwise(a, b):
	return (a.position - %Player.position).angle() < (b.position - %Player.position).angle()
			
func _on_start_timer_timeout() -> void:
	var candidates: Array[Area2D] = %NetTarget.get_overlapping_areas().filter(func(e): return !e.removed_from_net)
	if candidates.size() < 4:
		return
	
	if planes.is_empty():
		var has_top: bool = false
		var has_bottom: bool = false
		var has_left: bool = false
		var has_right: bool = false
		for plane in candidates:
			if !has_top && plane.position.y < %Player.position.y:
				has_top = true
			if !has_bottom && plane.position.y > %Player.position.y:
				has_bottom = true
			if !has_left && plane.position.x < %Player.position.x:
				has_left = true
			if !has_right && plane.position.x > %Player.position.x:
				has_right = true
		
		if !has_top || !has_bottom || !has_left || !has_right:
			return
		
		var vertices: PackedVector2Array
		
		planes = candidates
		
		planes.sort_custom(sort_clockwise)
		planes[0].ready_for_net = true
		planes[1].ready_for_net = true
		for i in range(planes.size()):
			vertices.append(planes[0].position)
		set_polygon(vertices)
	elif candidates.size() > planes.size():
		var vertices: PackedVector2Array = polygon
		entire_net_connected = false
		for plane in planes:
			if !candidates.has(plane):
				candidates.append(plane)
			
		candidates.sort_custom(sort_clockwise)
		while planes[0] != candidates[0]:
			candidates.push_front(candidates.pop_back())
			
		for i in range(candidates.size()):
			if i >= planes.size():
				planes.append(candidates[i])
				if i + 1 >= candidates.size():
					vertices.append(candidates[0].position)
				else:
					vertices.append(candidates[i + 1].position)
			elif planes[i] != candidates[i]:
				planes.insert(i, candidates[i])
				vertices.insert(i, candidates[i + 1].position)
		set_polygon(vertices)
