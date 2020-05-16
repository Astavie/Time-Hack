extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func open():
	get_node("AnimatedSprite").animation = "open";
	get_node("CollisionShape2D").disabled = true;
	get_node("LightOccluder2D").visible = false;
	pass;

func close():
	get_node("AnimatedSprite").animation = "default";
	get_node("CollisionShape2D").disabled = false;
	get_node("LightOccluder2D").visible = true;
	pass;
