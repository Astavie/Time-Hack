extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("pull"):
		get_tree().change_scene("res://scenes/Level1.tscn");
