extends Area2D

export(NodePath) var door;

func _process(delta):
	if get_overlapping_bodies().empty():
		if get_node("AnimatedSprite").animation != "default":
			if get_owner().frame_one == 0:
				get_node("AudioStreamPlayer").play();
			get_node(door).close();
		get_node("AnimatedSprite").animation = "default";
	else:
		if get_node("AnimatedSprite").animation != "pressed":
			if get_owner().frame_one == 0:
				get_node("AudioStreamPlayer").play();
			get_node(door).open();
		get_node("AnimatedSprite").animation = "pressed";
