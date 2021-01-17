class_name classVirtualViewport
extends Viewport

func change_scene_to(packed_scene : PackedScene) -> int:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	var original_size = Vector2(1024, 576)
	var scale_factor = size/original_size

	var new_child := packed_scene.instance()

	new_child.rect_scale = scale_factor

	add_child(new_child)

	return OK
