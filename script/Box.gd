extends "res://script/Movable.gd"

var velocity = Vector2.ZERO;

func _physics_process(delta):
	linear_velocity = velocity;
	velocity = Vector2.ZERO;
