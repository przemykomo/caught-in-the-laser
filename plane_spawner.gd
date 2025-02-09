extends Timer

@export var plane_scene: PackedScene

func _on_timeout() -> void:
	if get_tree().get_node_count_in_group("planes") < 7:
		wait_time *= 0.9
		var plane = plane_scene.instantiate()
		plane.position = Vector2.UP.rotated(randf_range(- PI, 0)) * 400
		plane.position.x += 310
		plane.position.y += 240
		plane.player = %Player
		plane.net = %Net
		get_parent().add_child(plane)
