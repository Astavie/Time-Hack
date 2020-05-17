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

var tutorial_num = 0;
var shown_ceo = false;

export var tutorial = false;
export(PackedScene) var nextLevel;

func _ready():
	get_node("Global/Music").play();
	init_material = material;
	hidden_material = get_node("hidden").material;
	if tutorial:
		tutorial_num = 1;
		transition = true;
		get_node("Tutorial/Hacker").visible = true;

func get_player():
	return get_node("Player");

func ceo():
	if !tutorial || shown_ceo:
		return false;
	
	shown_ceo = true;
	tutorial_num = 2;
	transition = true;
	get_node("Tutorial/CEO").visible = true;
	return true;

func lose():
	get_node("Global/Music").stop();
	if mode == 1:
		for moving in trackable:
			moving.rewind_stop();
	
	transition = true;
	get_node("Global/Alarm").play();
	lose_time = 1;

func die():
	get_node("Global/Music").stop();
	if lose_time > 0:
		return;
	
	transition = true;
	get_node("Global/Fall").play();
	if mode == 0:
		get_node("Global/DiePlayer/Node2D").visible = true;
	else:
		get_node("Global/DieCEO/Node2D").visible = true;

func laptop():
	get_node("Global/Music").stop();
	if lose_time > 0:
		return;
	
	transition = true;
	if mode == 0:
		get_node("Global/Win").play();
		get_node("Global/WinPlayer/Node2D").visible = true;
	else:
		get_node("Global/Fall").play();
		get_node("Global/LoseCEO/Node2D").visible = true;

func play_hack():
	get_node("Global/Hack").play();

func play_mode(mode):
	next_mode = mode;

func _process(delta):
	#if !transition && Input.is_action_just_pressed("switch"):
	#	play_mode(abs(mode - 1));
	#if !transition && Input.is_action_just_pressed("nextlevel"):
	#	get_tree().change_scene_to(nextLevel);
	#	return;
	
	if tutorial_num > 0 && Input.is_action_just_pressed("pull"):
		tutorial_num = 0;
		transition = false;
		get_node("Tutorial/Hacker").visible = false;
		get_node("Tutorial/CEO").visible = false;
	
	if next_mode != -1:
		get_node("Global/Music").play();
		
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
		
		if mode == 1:
			ceo();
	
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
