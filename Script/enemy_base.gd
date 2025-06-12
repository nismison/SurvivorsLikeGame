extends CharacterBody2D
class_name EnemyBase

@export var enemy_speed: float = 100.0
@export var enemy_health: float = 100.0
@export var enemy_godmode: bool = false
@export var attack_damage: int = 10
@export var chest_scene: PackedScene
@export var min_distance_to_player: float = 200

@onready var enemy_sprite: AnimatedSprite2D
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var flash_material: ShaderMaterial

# 状态枚举
enum EnemyState {
	IDLE,
	MOVING,
	ATTACKING,
	STUNNED
}

var current_state: EnemyState = EnemyState.IDLE

func _ready():
	# 子类初始化方法
	init_enemy()
	
	add_to_group("enemy")
	set_collision_layer_value(1, false)  # 不是player
	set_collision_mask_value(1, false)   # 不和player碰撞
	
	set_collision_layer_value(4, true)  # 指定为Enemy层
	set_collision_layer_value(4, true)  # 和Enemy碰撞
	set_collision_mask_value(7, true)   # 和阻挡区域碰撞
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	flash_material = enemy_sprite.material as ShaderMaterial
	z_index = 5

# 子类初始化入口 在子类脚本中重写
func init_enemy() -> void:
	pass

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	if not enemy_sprite:
		print("没有指定敌人Sprite，请检查！")
		return
	
	# 子类可以重写这个方法来实现不同的行为
	handle_behavior(delta)
	
	
# 基础行为，子类可以重写
func handle_behavior(delta: float):
	var to_player = player.global_position - global_position
	if to_player.length() > min_distance_to_player:
		var move_dir = (player.global_position - global_position).normalized()
		velocity = move_dir * enemy_speed
		current_state = EnemyState.MOVING
	else:
		velocity = Vector2.ZERO
		current_state = EnemyState.IDLE
	move_and_slide()
	
	# 处理翻转
	if velocity.x < -1:
		enemy_sprite.flip_h = true  # 向左
	elif velocity.x > 1:
		enemy_sprite.flip_h = false  # 向右
	
	# 更新动画
	if velocity.length() > 0.1:
		enemy_sprite.play("walk")
	else:
		enemy_sprite.play("idle")

# 造成伤害
func take_damage():
	if enemy_godmode:
		print("Enemy 无敌状态中！")
		return
	var damage = PlayerData.damage_total
	print("Enemy 被击中了！伤害：" + str(damage))
	flash_white()
	calculate_health(damage)

# 击中闪白
func flash_white():
	if flash_material == null:
		return
	flash_material.set_shader_parameter("flash", true)
	flash_material.set_shader_parameter("flash_strength", 0.5)
	flash_material.set_shader_parameter("enable_outline", false)
	await get_tree().create_timer(0.1).timeout
	flash_material.set_shader_parameter("flash", false)

# 计算血量
func calculate_health(damage: float):
	enemy_health = max(enemy_health - damage, 0)
	
	# 敌人死亡
	if enemy_health <= 0:
		# TODO 敌人死亡掉落
		#genarate_drop_item()
		queue_free()

# 获取到玩家的距离
func get_distance_to_player() -> float:
	if player == null:
		return INF
	return global_position.distance_to(player.global_position)


func genarate_drop_item() -> void:
	var all_relic_items = ItemDatabase.get_all_item_ids()

	var array_size = all_relic_items.size()
	var random_index = randi() % array_size
	var drop_item_id = all_relic_items[random_index]

	var relic_object = ItemDatabase.get_item_resource(drop_item_id)
	print("生成的drop_item ID: ", relic_object, " 地址: ", str(relic_object.get_instance_id()))

	
	print("掉落物品： %s" % relic_object.name)
	
	var drop_item_scene = preload("res://Scenes/drop_item.tscn")
	var drop_item_instant = drop_item_scene.instantiate()
	drop_item_instant.drop_item = relic_object
	drop_item_instant.global_position = global_position
	
	get_tree().get_root().call_deferred("add_child", drop_item_instant)
