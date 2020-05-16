extends Area2D

var enabled = true;
var in_range = false;

var time = 0;

static func lerp_angle(a, b, t):
	if abs(a-b) >= PI:
		if a > b:
			a = normalize_angle(a) - 2.0 * PI
		else:
			b = normalize_angle(b) - 2.0 * PI
	return lerp(a, b, t)

static func normalize_angle(x):
	return fposmod(x + PI, 2.0*PI) - PI

func _ready():
	get_owner().trackable.push_back(self);
	get_owner().lights.push_back(get_node("Light2D"));

func _input_event(viewport, event, shape_idx):
	if get_owner().transition || time > 0:
		return;
		
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed \
	and is_in_range():
		if enabled:
			hack();
		else:
			unhack();

func _physics_process(delta):
	if get_owner().transition || time > 0:
		return;
	
	var player = get_owner().get_player();
	var light = get_node("Light2D");
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(player.get_global_position(), light.get_global_position(), [player], collision_mask);
	in_range = !result;
	
	if !enabled || abs(normalize_angle(get_node("Camera").rotation)) > 0.01:
		return;
	
	var angle = normalize_angle((player.get_global_position() - light.get_global_position()).angle() - light.get_global_rotation());
	if (angle > 0 || angle < -PI/2): # Check if inside cone
		if (!overlaps_body(player)): # Check if underneath camera
			return;
		
	if in_range:
		get_node("Beep").play();
		get_node("Camera/ColorRect").visible = true;
		time = 0.2; # Set lose timer

func _process(delta):
	if time > 0:
		time -= delta;
		if time <= 0:
			get_owner().lose();
	
	var angle = 0;
	if !enabled:
		angle = -PI / 6;
	
	if get_owner().frame_one == 0:
		get_node("Camera").rotation = lerp_angle(get_node("Camera").rotation, angle, .2);
	else:
		get_node("Camera").rotation = angle;
	
	if (enabled && abs(normalize_angle(get_node("Camera").rotation - angle)) < 0.01):
		get_node("Light2D").visible = true;
		get_node("Light").visible = get_owner().mode == 1;

func is_in_range():
	return get_owner().mode == 1 || in_range;

# Hackable

var prev = false;
var hacked = [];

func record():
	if is_hacked() == prev:
		hacked.push_back(null);
	else:
		hacked.push_back(is_hacked());
		prev = is_hacked();

func reset():
	if (get_owner().mode == 0):
		hacked = [];
	unhack();
	get_node("Light").visible = get_owner().mode == 1;
	get_node("Light2D").visible = true;
	get_node("Camera/ColorRect").visible = false;
	get_node("Camera").rotation = 0;

func rewind(frame):
	if frame < hacked.size():
		var ish = hacked[frame];
		if ish != null && ish != is_hacked():
			if ish:
				hack();
			else:
				unhack();

func hack():
	if get_owner().frame_one == 0:
		get_owner().play_hack();
	
	get_node("Light2D").visible = false;
	get_node("Light").visible = false;
	enabled = false;

func unhack():
	if get_owner().frame_one == 0:
		get_owner().play_hack();
	
	enabled = true;

func is_hacked():
	return !enabled;

func rewind_stop():
	pass;
