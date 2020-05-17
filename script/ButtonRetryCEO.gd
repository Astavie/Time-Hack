extends Button

func _pressed():
	var owner = get_owner().get_owner();
	if owner == null:
		owner = get_owner();
	
	owner.play_mode(1);
	
	get_parent().visible = false;
	pressed = false;
