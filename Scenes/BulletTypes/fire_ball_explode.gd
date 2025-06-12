extends Node2D

@onready var anim = $AnimatedSprite2D

func _ready():
	z_index = 6
	anim.animation_finished.connect(queue_free)
