extends Area2D

var open = false;

func _ready():
	get_owner().trackable.push_back(self);

func _input_event(viewport, event, shape_idx):
	if get_owner().transition:
		return;
	
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed \
	and is_in_range(get_global_mouse_position()):
		if open:
			unhack();
		else:
			hack();

func _physics_process(delta):
	if !get_owner().transition && open:
		var bodies = get_overlapping_bodies();
		for body in bodies:
			if body.has_method("fall"):
				var body_extents = body.get_node("CollisionShape2D").shape.extents;
				var area_extents = self.get_node("CollisionShape2D").shape.extents;
				var body_rect = Rect2(body.global_position - body_extents, body_extents * 2);
				var area_rect = Rect2(self.global_position - area_extents, area_extents * 2);
				if area_rect.encloses(body_rect):
					body.fall();

func is_in_range(mouse):
	if get_owner().mode == 1:
		return true;
	var player = get_owner().get_player();
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(player.get_global_position(), mouse, [player, self], collision_mask);
	return !result;


func _process(delta):
	var area_extents = self.get_node("CollisionShape2D").shape.extents;
	var area_rect = Rect2(self.global_position - area_extents, area_extents * 2);
	get_node("ColorRect").visible = area_rect.has_point(get_global_mouse_position());

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
	
	get_node("AnimatedSprite").animation = "open";
	get_node("ColorRect/Desc").text = "Replace";
	open = true;

func unhack():
	if get_owner().frame_one == 0:
		get_owner().play_hack();
	
	get_node("AnimatedSprite").animation = "default";
	get_node("ColorRect/Desc").text = "Remove";
	open = false;

func is_hacked():
	return open;

func rewind_stop():
	pass;
