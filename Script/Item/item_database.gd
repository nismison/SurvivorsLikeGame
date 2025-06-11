extends Node

# 存储所有道具的字典
var items: Dictionary = {}
var item_resources: Dictionary = {}
var item_types: Dictionary = {}
var rarities: Dictionary = {}

# JSON文件路径
const ITEMS_JSON_PATH = "res://data/items.json"

func _ready():
	load_items_from_json()

# 从JSON文件加载道具数据
func load_items_from_json():
	var file = FileAccess.open(ITEMS_JSON_PATH, FileAccess.READ)
	if not file:
		print("无法打开道具数据文件: ", ITEMS_JSON_PATH)
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("JSON解析失败: ", json.get_error_message())
		return
	
	var data = json.data
	
	# 加载道具类型信息
	if data.has("item_types"):
		item_types = data.item_types
	
	# 加载稀有度信息
	if data.has("rarities"):
		rarities = data.rarities
	
	# 加载道具数据
	if data.has("items"):
		for item_data in data.items:
			var item = Item.from_json(item_data)
			item_resources[item.id] = item
		
		print("成功加载 %d 个道具" % item_resources.size())
	else:
		print("JSON文件中未找到道具数据")

# 重新加载道具数据（用于热更新）
func reload_items():
	item_resources.clear()
	items.clear()
	load_items_from_json()

# 创建道具实例
func create_item(item_id: int, quantity: int = 1) -> Dictionary:
	if item_id in item_resources:
		return {
			"id": item_id,
			"quantity": quantity,
			"resource": item_resources[item_id]
		}
	else:
		print("道具ID %d 不存在" % item_id)
		return {}

# 获取道具Resource
func get_item_resource(item_id: int) -> Item:
	return item_resources.get(item_id, null)

# 根据类型获取道具列表
func get_items_by_type(item_type: Item.ItemType) -> Array[Item]:
	var result: Array[Item] = []
	for item in item_resources.values():
		if item.item_type == item_type:
			result.append(item)
	return result

# 根据稀有度获取道具列表
func get_items_by_rarity(rarity: Item.Rarity) -> Array[Item]:
	var result: Array[Item] = []
	for item in item_resources.values():
		if item.rarity == rarity:
			result.append(item)
	return result

# 搜索道具（根据名称）
func search_items(search_term: String) -> Array[Item]:
	var result: Array[Item] = []
	var search_lower = search_term.to_lower()
	
	for item in item_resources.values():
		if item.name.to_lower().contains(search_lower) or item.description.to_lower().contains(search_lower):
			result.append(item)
	
	return result

# 获取所有道具ID列表
func get_all_item_ids() -> Array[int]:
	var ids: Array[int] = []
	for id in item_resources.keys():
		ids.append(id)
	return ids

# 获取道具类型的中文名称
func get_item_type_name(type_str: String) -> String:
	return item_types.get(type_str, type_str)

# 获取稀有度信息
func get_rarity_info(rarity_str: String) -> Dictionary:
	return rarities.get(rarity_str, {"name": rarity_str, "color": "#FFFFFF"})

# 保存道具数据到文件（玩家背包数据）
func save_items_to_file(items_data: Array, file_path: String = "user://items.save"):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(items_data))
		file.close()
		print("道具数据已保存")

# 从文件加载道具数据（玩家背包数据）
func load_items_from_file(file_path: String = "user://items.save") -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			return json.data
	return []

# 验证道具数据完整性
func validate_item_data() -> bool:
	var valid = true
	
	for item_id in item_resources:
		var item = item_resources[item_id]
		
		# 检查必要字段
		if item.name == "":
			print("警告: 道具ID %d 缺少名称" % item_id)
			valid = false
		
		if item.icon_path != "" and not ResourceLoader.exists(item.icon_path):
			print("警告: 道具ID %d 的图标路径不存在: %s" % [item_id, item.icon_path])
	
	return valid
