extends Area2D

class_name BulletBase

@onready var bullet_explode: AnimatedSprite2D = $BulletExplode
@onready var bullet: Node2D = $Bullet
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


@export var speed := 300.0

var direction := Vector2.ZERO
var start_position: Vector2
var exploded := false


func _ready() -> void:
	add_to_group("bullet")
	z_index = 6
	
	start_position = global_position
	scale = scale + scale * PlayerData.bullet_scale_modifier


func _process(delta):
	if not exploded:
		position += direction * speed * delta
		
		if global_position.distance_to(start_position) > PlayerData.atk_distance_total:
			queue_free()
	

# 生成爆炸特效
func spawn_explosion():
	if exploded:
		return
	
	exploded = true
	bullet.visible = false
	collision_shape.set_deferred("disabled", true)
	bullet_explode.visible = true
	bullet_explode.play("explode")
	await bullet_explode.animation_finished
	
	exploded = false
	queue_free()
