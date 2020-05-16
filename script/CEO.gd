extends Camera2D

var grab = Vector2.ZERO;
var prev = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !current:
		return;
	
	if !prev && Input.is_mouse_button_pressed(BUTTON_LEFT):
		prev = true;
		grab = get_local_mouse_position();
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		var movement = grab - get_local_mouse_position();
		if movement != Vector2.ZERO:
			grab = get_local_mouse_position();
			translate(movement);
	else:
		prev = false;
