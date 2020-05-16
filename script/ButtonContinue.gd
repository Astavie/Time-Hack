extends Button

func _pressed():
	var owner = get_owner().get_owner();
	if owner == null:
		owner = get_owner();
	
	var scene = owner.nextLevel;
	if scene != null:
		get_tree().change_scene_to(scene);
