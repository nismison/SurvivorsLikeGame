extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_distance: float = 20.0   # 距离摄像机多远生成
@export var spawn_interval: float = 0.5    # 生成间隔（秒）
@export var max_enemies: int = 100          # 最大敌人数量

@onready var characters_node: Node2D = $Characters

var camera: Camera2D

func _ready():
	# 获取摄像机和Characters节点的引用
	camera = get_viewport().get_camera_2d()
	
	# 启动生成定时器
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_enemy)
	timer.start()

func _spawn_enemy():
	# 检查是否达到最大敌人数量
	if get_current_enemy_count() >= max_enemies:
		return
	
	if camera == null or enemy_scene == null:
		return
	
	# 获取摄像机位置和视口大小
	var camera_pos = camera.global_position
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_rect = Rect2(
		camera_pos - viewport_size * 0.5 / camera.zoom,
		viewport_size / camera.zoom
	)
	
	# 生成随机位置（在摄像机范围外）
	var spawn_pos = get_random_spawn_position(camera_rect)
	
	# 实例化敌人
	var enemy = enemy_scene.instantiate()
	characters_node.add_child(enemy)
	enemy.global_position = spawn_pos

func get_random_spawn_position(camera_rect: Rect2) -> Vector2:
	# 创建一个更大的矩形，用于在摄像机外围生成
	var expanded_rect = camera_rect.grow(spawn_distance)
	
	# 随机选择一个边界
	var side = randi() % 4
	var spawn_pos: Vector2
	
	match side:
		0: # 上边
			spawn_pos = Vector2(
				randf_range(expanded_rect.position.x, expanded_rect.position.x + expanded_rect.size.x),
				expanded_rect.position.y
			)
		1: # 右边
			spawn_pos = Vector2(
				expanded_rect.position.x + expanded_rect.size.x,
				randf_range(expanded_rect.position.y, expanded_rect.position.y + expanded_rect.size.y)
			)
		2: # 下边
			spawn_pos = Vector2(
				randf_range(expanded_rect.position.x, expanded_rect.position.x + expanded_rect.size.x),
				expanded_rect.position.y + expanded_rect.size.y
			)
		3: # 左边
			spawn_pos = Vector2(
				expanded_rect.position.x,
				randf_range(expanded_rect.position.y, expanded_rect.position.y + expanded_rect.size.y)
			)
	
	return spawn_pos

func get_current_enemy_count() -> int:
	# 计算当前PlantEnemy数量
	var count = 0
	for child in characters_node.get_children():
		if child.scene_file_path.contains("Enemy"):
			count += 1
	print("敌人数量： %s" % count)
	return count
