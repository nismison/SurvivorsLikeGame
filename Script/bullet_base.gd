extends Area2D

class_name BulletBase


@export var explosion_scene: PackedScene  # ⬅️ 指向爆炸特效
@export var speed := 300.0
@export var damage: float = 20

var direction := Vector2.ZERO
var start_position: Vector2
var exploded := false


func _ready() -> void:
	add_to_group("bullet")
	
	start_position = global_position


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
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	
	exploded = false
	queue_free()
