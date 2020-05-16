extends RigidBody2D

var movement = [];
var initial;

# Called when the node enters the scene tree for the first time.
func _ready():
	get_owner().trackable.push_back(self);
	initial = [is_flipped(), get_position()];

func record():
	movement.push_back([is_flipped(), get_position()]);
	pass;

func rewind(frame):
	if frame < movement.size():
		var thing = movement[frame];
		rewind_position(thing[1], thing[0]);
	else:
		rewind_stop();

func reset():
	if (get_owner().mode == 0):
		movement = [];
	rewind_position(initial[1], initial[0]);

func is_flipped():
	return false;

func rewind_position(vec, flip):
	set_position(vec);

func rewind_stop():
	pass;
