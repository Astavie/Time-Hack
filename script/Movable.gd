extends RigidBody2D

var movement = [];
var initial;

var falling = false;
var s = 1;

func _ready():
	get_owner().trackable.push_back(self);
	initial = [is_flipped(), get_position()];

func _process(delta):
	if falling:
		rotation += PI * delta;
		s *= 1.05
		scale /= s;

func record():
	movement.push_back([is_flipped(), get_position()]);
	pass;

func fall():
	falling = true;
	get_node("CollisionShape2D").disabled = true;
	var occluder = get_node("LightOccluder2D");
	if occluder != null:
		occluder.visible = false;

func rewind(frame):
	if !falling:
		if frame < movement.size():
			var thing = movement[frame];
			rewind_position(thing[1], thing[0]);
		else:
			rewind_stop();

func reset():
	falling = false;
	rotation = 0;
	s = 1;
	scale = Vector2(1, 1);
	get_node("CollisionShape2D").disabled = false;
	var occluder = get_node("LightOccluder2D");
	if occluder != null:
		occluder.visible = true;
	
	if (get_owner().mode == 0):
		movement = [];
	rewind_position(initial[1], initial[0]);

func is_flipped():
	return false;

func rewind_position(vec, flip):
	set_position(vec);

func rewind_stop():
	pass;
