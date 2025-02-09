extends Timer

@export var icbm_scene: PackedScene
@export var is_dumb: bool

func _on_timeout() -> void:
	var icbm = icbm_scene.instantiate()
	icbm.position = Vector2.UP.rotated(randf_range(- PI, 0)) * 400
	icbm.position.x += 310
	icbm.position.y += 240
	icbm.player = %Player
	icbm.is_dumb = is_dumb
	get_parent().add_child(icbm)
