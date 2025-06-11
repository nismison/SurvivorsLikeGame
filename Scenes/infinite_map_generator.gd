extends Node

# 子节点引用
@onready var map_background: TileMapLayer = $MapBackground
@onready var grass_terrain: TileMapLayer = $GrassTerrain

# 玩家引用 - 需要在编辑器中设置或通过代码获取
@export var player: Node2D = null

# 噪声图（只用于装饰层）
@export var decoration_noise: FastNoiseLite = null
@export var decoration_density: float = 0.3  # 装饰密度控制 (0-1)
@export var decoration_threshold: float = 0.6  # 装饰生成阈值

# 地形生成参数
@export var generation_radius: int = 64  # 玩家周围生成地形的半径（以图块为单位）
@export var tile_size: int = 16  # 图块大小（像素）
@export var update_distance: float = 32.0  # 玩家移动多少距离后更新地形

# 记录已生成的区块
var generated_chunks: Dictionary = {}
var chunk_size: int = 16  # 每个区块的大小
var last_player_position: Vector2 = Vector2.ZERO

# 存储图块集0中所有可用的装饰图块坐标
var decoration_tiles: Array[Vector2i] = []

func _ready() -> void:
	set_up_decoration_noise()
	get_decoration_tiles()
	
	# 如果没有设置玩家引用，尝试自动查找
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			print("警告：没有找到玩家节点，请设置player变量或将玩家添加到'player'组")
			return
	
	# 初始生成玩家周围的地形
	if player:
		generate_around_player()

func _process(_delta: float) -> void:
	if player == null:
		return
	
	# 检查玩家是否移动了足够的距离
	var current_position = player.global_position
	if current_position.distance_to(last_player_position) > update_distance:
		generate_around_player()
		last_player_position = current_position

func generate_around_player() -> void:
	"""在玩家周围生成地形"""
	if player == null:
		return
	
	var player_tile_pos = world_to_tile_pos(player.global_position)
	
	# 计算需要生成的区块范围
	var chunk_radius = (generation_radius + chunk_size - 1) / chunk_size  # 向上取整
	
	for chunk_x in range(-chunk_radius, chunk_radius + 1):
		for chunk_y in range(-chunk_radius, chunk_radius + 1):
			var chunk_coord = Vector2i(
				player_tile_pos.x / chunk_size + chunk_x,
				player_tile_pos.y / chunk_size + chunk_y
			)
			
			# 如果这个区块还没有生成，则生成它
			if not generated_chunks.has(chunk_coord):
				generate_chunk(chunk_coord)
				generated_chunks[chunk_coord] = true

func generate_chunk(chunk_coord: Vector2i) -> void:
	"""生成指定的区块"""
	var start_x = chunk_coord.x * chunk_size
	var start_y = chunk_coord.y * chunk_size
	
	for x in range(start_x, start_x + chunk_size):
		for y in range(start_y, start_y + chunk_size):
			# 生成背景
			generate_background_tile(x, y)
			# 生成装饰
			generate_decoration_tile(x, y)

func generate_background_tile(x: int, y: int) -> void:
	"""生成单个背景图块"""
	map_background.set_cell(Vector2i(x, y), 1, Vector2i(1, 12), 0)

func generate_decoration_tile(x: int, y: int) -> void:
	"""生成单个装饰图块"""
	if decoration_tiles.is_empty():
		return
	
	# 获取装饰噪声值
	var decoration_noise_value = decoration_noise.get_noise_2d(x, y)
	
	# 将噪声值从 [-1, 1] 范围转换到 [0, 1]
	var normalized_noise = (decoration_noise_value + 1.0) / 2.0
	
	# 只在噪声值超过阈值时放置装饰
	if normalized_noise > decoration_threshold:
		# 使用噪声值和位置信息创建伪随机索引
		var random_seed = int((normalized_noise * 1000) + x * 73 + y * 37) % 1000
		var decoration_index = random_seed % decoration_tiles.size()
		var selected_tile = decoration_tiles[decoration_index]
		
		# 在GrassTerrain节点中放置装饰 (使用图块集0)
		grass_terrain.set_cell(Vector2i(x, y), 0, selected_tile, 0)

func world_to_tile_pos(world_pos: Vector2) -> Vector2i:
	"""将世界坐标转换为图块坐标"""
	return Vector2i(int(world_pos.x / tile_size), int(world_pos.y / tile_size))

func set_up_decoration_noise() -> void:
	"""设置装饰噪声图"""
	randomize()
	
	if decoration_noise == null:
		decoration_noise = FastNoiseLite.new()
	
	decoration_noise.seed = randi()
	decoration_noise.frequency = 1  # 较低频率，产生更大的装饰区域
	decoration_noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC

func get_decoration_tiles() -> void:
	"""获取图块集0中所有可用的装饰图块坐标"""
	decoration_tiles.clear()
	
	# 从GrassTerrain节点获取图块集
	var tile_set = grass_terrain.tile_set
	if tile_set == null:
		print("警告：GrassTerrain节点没有设置TileSet")
		return
	
	var source = tile_set.get_source(0) as TileSetAtlasSource
	if source == null:
		print("警告：图块集0不存在或不是AtlasSource类型")
		return
	
	# 遍历所有图块坐标
	for i in range(source.get_tiles_count()):
		var atlas_coords = source.get_tile_id(i)
		decoration_tiles.append(atlas_coords)
	
	print("找到 ", decoration_tiles.size(), " 个装饰图块")

func clean_all_maps() -> void:
	"""清空所有地图层和生成记录"""
	map_background.clear()
	grass_terrain.clear()
	generated_chunks.clear()

func clean_distant_chunks() -> void:
	"""清理距离玩家较远的区块以节省内存"""
	if player == null:
		return
	
	var player_tile_pos = world_to_tile_pos(player.global_position)
	var player_chunk = Vector2i(
		player_tile_pos.x / chunk_size,
		player_tile_pos.y / chunk_size
	)
	
	var cleanup_radius = generation_radius * 2  # 清理半径是生成半径的2倍
	var chunks_to_remove: Array[Vector2i] = []
	
	for chunk_coord in generated_chunks.keys():
		var distance = Vector2(chunk_coord - player_chunk).length()
		if distance > cleanup_radius:
			chunks_to_remove.append(chunk_coord)
	
	# 清理远离的区块
	for chunk_coord in chunks_to_remove:
		clear_chunk(chunk_coord)
		generated_chunks.erase(chunk_coord)

func clear_chunk(chunk_coord: Vector2i) -> void:
	"""清除指定区块的图块"""
	var start_x = chunk_coord.x * chunk_size
	var start_y = chunk_coord.y * chunk_size
	
	for x in range(start_x, start_x + chunk_size):
		for y in range(start_y, start_y + chunk_size):
			map_background.erase_cell(Vector2i(x, y))
			grass_terrain.erase_cell(Vector2i(x, y))

# 手动触发清理的函数
func _on_cleanup_timer_timeout() -> void:
	"""定期清理远离的区块 - 可以连接到Timer节点"""
	clean_distant_chunks()

# 调试函数
func get_generated_chunks_count() -> int:
	return generated_chunks.size()

func force_regenerate_around_player() -> void:
	"""强制重新生成玩家周围的地形"""
	if player == null:
		return
	
	var player_tile_pos = world_to_tile_pos(player.global_position)
	var chunk_radius = (generation_radius + chunk_size - 1) / chunk_size
	
	for chunk_x in range(-chunk_radius, chunk_radius + 1):
		for chunk_y in range(-chunk_radius, chunk_radius + 1):
			var chunk_coord = Vector2i(
				player_tile_pos.x / chunk_size + chunk_x,
				player_tile_pos.y / chunk_size + chunk_y
			)
			
			# 清除旧的区块
			if generated_chunks.has(chunk_coord):
				clear_chunk(chunk_coord)
			
			# 重新生成
			generate_chunk(chunk_coord)
			generated_chunks[chunk_coord] = true
