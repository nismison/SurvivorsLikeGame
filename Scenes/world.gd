extends Node2D

var spawn_distance: float = 20.0   # 距离摄像机多远生成
var spawn_interval: float = 0.5    # 生成间隔（秒）
var max_enemies: int = 1          # 最大敌人数量

@onready var characters_node: Node2D = $Characters
@onready var level_up_canvas: CanvasLayer = $LevelUpCanvas
@onready var level_up_scene: Control = $LevelUpCanvas/LevelUpScene

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
	
	PlayerData.level_up.connect(_on_player_level_up)
	PlayerData.relic_changed.connect(_close_level_up_scene)

func _spawn_enemy():
	# 检查是否达到最大敌人数量
	if get_current_enemy_count() >= max_enemies:
		return
	
	if camera == null: return
	
	# 获取摄像机位置和视口大小
	var camera_pos = camera.global_position
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_rect = Rect2(
		camera_pos - viewport_size * 0.5 / camera.zoom,
		viewport_size / camera.zoom
	)
	
	# 生成随机位置（在摄像机范围外）
	var spawn_pos = get_random_spawn_position(camera_rect)
	
	# 实例化随机类型敌人
	var enemy_types := ["goblin", "plant", "skeleton"]
	var enemy_rand_type = enemy_types[randi_range(0, len(enemy_types) - 1)]
	var enemy_scene_path := "res://Scenes/Enemy/%s_enemy.tscn" % enemy_rand_type
	var enemy_scene = load(enemy_scene_path)
	
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
	# 计算当前敌人数量
	var count = 0
	for child in characters_node.get_children():
		if child.scene_file_path.contains("Enemy"):
			count += 1
	return count
	

# 玩家升级
func _on_player_level_up() -> void:
	get_tree().paused = true
	level_up_scene.genarate_drop_item()
	level_up_canvas.visible = true


# 关闭升级窗口
func _close_level_up_scene() -> void:
	if level_up_canvas.visible:
		level_up_canvas.visible = false
		get_tree().paused = false


func _on_button_pressed() -> void:
	print("Test Button")
	#var _exp = LevelManager.get_level_required_exp(PlayerData.level + 1)
	#PlayerData.got_exp(_exp)
	
	
	# 添加遗物
	var all_relic_items = ItemDatabase.get_items_by_type("圣物")
	var array_size = all_relic_items.size()
	var random_index = randi() % array_size
	var bonus_item = all_relic_items[random_index]
	PlayerData.relic_add(bonus_item)
	print("添加圣物: %s" % bonus_item.name)
