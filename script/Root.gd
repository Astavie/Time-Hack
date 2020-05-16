extends Node2D

var transition = false;
var mode = 0; # 0 = hacker, 1 = CEO
var lose_time = 0;

var trackable = [];
var lights = [];
var frame_one = 0;

var init_material;
var hidden_material;

var next_mode = -1;
var frame = 0;

export var tutorial = false;
export(PackedScene) var nextLevel;

func _ready():
	init_material = material;
	hidden_material = get_node("hidden").material;

func get_player():
	return get_node("Player");

func lose():
	if mode == 1:
		for moving in trackable:
			moving.rewind_stop();
	
	transition = true;
	get_node("Global/Alarm").play();
	lose_time = 1;

func die():
	if lose_time > 0:
		return;
	
	transition = true;
	if mode == 0:
		get_node("Global/DiePlayer/Node2D").visible = true;
	else:
		get_node("Global/DieCEO/Node2D").visible = true;

func laptop():
	if lose_time > 0:
		return;
	
	transition = true;
	if mode == 0:
		get_node("Global/Win").play();
		get_node("Global/WinPlayer/Node2D").visible = true;
	else:
		get_node("Global/Light").play();
		get_node("Global/LoseCEO/Node2D").visible = true;

func play_hack():
	get_node("Global/Hack").play();

func play_mode(mode):
	next_mode = mode;

func _process(delta):
	if !transition && Input.is_action_just_pressed("switch"):
		play_mode(abs(mode - 1));
	
	if next_mode != -1:
		self.mode = next_mode;
		next_mode = -1;
		frame = 0;
		
		if mode == 1:
			get_node("CEO").set_position(get_node("Player/Camera2D").get_global_position());
			get_node("CEO").current = true;
		
		transition = false;
		get_node("Global/Alarm").stop();
		
		material = init_material;
		get_node("hidden").material = hidden_material;
		
		frame_one = 3;
		for moving in trackable:
			moving.reset();
	
	if lose_time > 0:
		lose_time -= delta;
		if lose_time <= 0:
			if mode == 0:
				get_node("Global/Light").play();
				get_node("Global/LosePlayer/Node2D").visible = true;
			else:
				get_node("Global/Win").play();
				get_node("Global/WinCEO/Node2D").visible = true;
			material = null;
			get_node("hidden").material = null;
			get_node("Player").material = null;
	elif !transition:
		if frame_one > 0:
			frame_one -= 1;
		if mode == 0:
			for moving in trackable:
				moving.record();
		else:
			for moving in trackable:
				moving.rewind(frame);
			frame += 1;
