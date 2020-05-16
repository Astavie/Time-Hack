extends "res://script/Movable.gd"

const MOVEMENT_SPEED = 240;
var move_angle = 0;
var target_angle = 0;

const hidden_material = preload("res://assets/hidden_material.tres");

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if get_parent().mode == 1:
		return;
	
	if linear_velocity.length_squared() < 0.1:
		get_node("AnimatedSprite").animation = "idle";
	else:
		get_node("AnimatedSprite").animation = "run";
	
	# MOVE
	if !get_parent().transition:
		var pulling = null;
		if (Input.is_action_pressed("pull")):
			pulling = get_node("Down").get_collider();
			if pulling == null:
				pulling = get_node("Up").get_collider();
				if pulling == null:
					pulling = get_node("Left").get_collider();
					if pulling == null:
						pulling = get_node("Right").get_collider();
		
		if pulling is StaticBody2D:
			# Computer!
			get_owner().laptop();
			return;
		
		var dir = Vector2();
		if (Input.is_action_pressed("move_up")):
			dir += Vector2(0, -1);
		if (Input.is_action_pressed("move_down")):
			dir += Vector2(0, 1);
		if (Input.is_action_pressed("move_left")):
			dir += Vector2(-1, 0);
		if (Input.is_action_pressed("move_right")):
			dir += Vector2(1, 0);
		
		dir = dir.normalized();
		linear_velocity = dir * MOVEMENT_SPEED;
		if pulling != null:
			linear_velocity /= 2;
			pulling.velocity = linear_velocity;
		
		get_node("Camera2D").align();
	else:
		linear_velocity = Vector2.ZERO;
		get_node("AnimatedSprite").animation = "idle";
	
	# LOOK
	var angle = get_local_mouse_position().angle();
	get_node("Light").rotation = angle + .25 * PI;
	
	get_node("AnimatedSprite").flip_h = abs(angle) > PI / 2;

# Movable
func is_flipped():
	return get_node("AnimatedSprite").flip_h;

func reset():
	.reset();
	get_node("AnimatedSprite").animation = "idle";
	get_node("Light").visible = get_owner().mode == 0;
	if get_owner().mode == 0:
		material = null;
		get_node("Camera2D").current = true;
	else:
		material = hidden_material;

func rewind_position(vec, flip):
	if (get_position() - vec).length_squared() > 0.1:
		get_node("AnimatedSprite").animation = "run";
	else:
		get_node("AnimatedSprite").animation = "idle";
	
	get_node("AnimatedSprite").flip_h = flip;
	set_position(vec);
	get_node("Camera2D").align();

func rewind(frame):
	if frame < movement.size():
		var thing = movement[frame];
		rewind_position(thing[1], thing[0]);
	else:
		get_owner().laptop();
		rewind_stop();

func rewind_stop():
	get_node("AnimatedSprite").animation = "idle";
	pass;
