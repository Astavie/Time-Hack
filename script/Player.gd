extends KinematicBody2D

const MOVEMENT_SPEED = 240;
var move_angle = 0;
var target_angle = 0;

const hidden_material = preload("res://assets/hidden_material.tres");

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if get_parent().mode == 1:
		return;
	
	# MOVE
	if !get_parent().transition && !falling:
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
		if dir == Vector2.ZERO:
			get_node("AnimatedSprite").animation = "idle";
		else:
			var factor = 1;
			if pulling != null:
				factor = 0.5;
			
			var anim = "idle";
			
			var velocity = move_and_slide(dir * MOVEMENT_SPEED * factor, Vector2.ZERO, false, 4, PI/4, false);
			if velocity.length_squared() > 0:
				anim = "run";
			
			for index in get_slide_count():
				var collision = get_slide_collision(index);
				if collision.collider is RigidBody2D:
					var collider = collision.collider;
					collider.velocity = dir * MOVEMENT_SPEED / 2;
					anim = "run";
			
			get_node("AnimatedSprite").animation = anim;
			
			if pulling != null:
				pulling.velocity = dir * MOVEMENT_SPEED / 2;
			
			get_node("Camera2D").align();
	else:
		get_node("AnimatedSprite").animation = "idle";
	
	# LOOK
	var angle = get_local_mouse_position().angle();
	get_node("Light").rotation = angle + .25 * PI;
	
	get_node("AnimatedSprite").flip_h = abs(angle) > PI / 2;

# Movable

var prev;
var move = 0;

var movement = [];
var initial;

var falling = false;

func _process(delta):
	if falling:
		rotation += PI * delta;
		scale /= 1.05;
	
	move += (position - prev).length();
	prev = position;
	if move > 64:
		move = 0;
		if get_owner().frame_one == 0:
			get_node("AudioStreamPlayer").play();

func fall():
	falling = true;
	get_node("Light").visible = false;
	get_owner().die();

func _ready():
	prev = position;
	get_owner().trackable.push_back(self);
	initial = [is_flipped(), get_position()];
	
func is_flipped():
	return get_node("AnimatedSprite").flip_h;

func reset():
	falling = false;
	rotation = 0;
	scale = Vector2(1, 1);
	
	if (get_owner().mode == 0):
		movement = [];
	rewind_position(initial[1], initial[0]);
	
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

func record():
	movement.push_back([is_flipped(), get_position()]);

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
