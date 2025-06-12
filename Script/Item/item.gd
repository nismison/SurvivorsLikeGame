extends Resource
class_name Item

# 道具的基本属性
@export var id: int
@export var name: String
@export var description: String
@export var icon: Texture2D
@export var icon_path: String
@export var price: int
@export var stack_size: int = 1
@export var item_type: String = "圣物"
@export var rarity: String = "普通"
@export var scene: String
@export var attack_speed: float
@export var damage: float
@export var atk_distance: float

# 道具属性字典（用于存储额外属性）
@export var stats: Dictionary = {}
@export var modifier: Dictionary = {}  # 加成属性
@export var quest_id: int = 0

# 道具类型枚举
enum ItemType {
	RELIC,
	WEAPON,
	ARMOR,
	MATERIAL,
	QUEST
}

# 稀有度枚举
enum Rarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY,
	SPECIAL
}

# 构造函数
func _init(p_id: int = 0):
	id = p_id

# 从JSON数据创建道具
static func from_json(json_data: Dictionary) -> Item:
	var item = Item.new()
	
	# 基本属性
	item.id = json_data.get("id", 0)
	item.name = json_data.get("name", "")
	item.description = json_data.get("description", "")
	item.icon_path = json_data.get("icon_path", "")
	item.price = json_data.get("price", 0)
	item.stack_size = json_data.get("stack_size", 1)
	item.scene = json_data.get("scene", "")
	item.attack_speed = json_data.get("attack_speed", 0)
	item.damage = json_data.get("damage", 0)
	item.atk_distance = json_data.get("atk_distance", 0)
	
	# 道具类型转换
	var type_str = json_data.get("item_type", "RELIC")
	item.item_type = string_to_item_type(type_str)
	
	# 稀有度转换
	var rarity_str = json_data.get("rarity", "COMMON")
	item.rarity = string_to_rarity(rarity_str)
	
	# 额外属性
	item.stats = json_data.get("stats", {})
	item.modifier = json_data.get("modifier", {})
	item.quest_id = json_data.get("quest_id", 0)
	
	# 加载图标
	item.load_icon()
	
	return item

# 字符串转道具类型
static func string_to_item_type(type_str: String) -> String:
	match type_str:
		"RELIC": return "圣物"
		"WEAPON": return "武器"
		"ARMOR": return "弹药"
		"MATERIAL": return "材料"
		"QUEST": return "探索"
		_: return "圣物"

# 字符串转稀有度
static func string_to_rarity(rarity_str: String) -> String:
	match rarity_str:
		"COMMON": return "普通"
		"RARE": return "稀有"
		"EPIC": return "史诗"
		"LEGENDARY": return "传说"
		"SPECIAL": return "神话"
		_: return "普通"

# 加载图标纹理
func load_icon():
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon = load(icon_path)

# 获取道具信息的方法
func get_info() -> String:
	var info = "名称: %s\n描述: %s\n价格: %d金币" % [name, description, price]
	
	# 添加属性信息
	if not stats.is_empty():
		info += "\n属性:"
		for stat_name in stats:
			info += "\n  %s: %s" % [stat_name, stats[stat_name]]
	
	# 添加加成信息
	#if not modifier.is_empty():
		#info += "\n加成:"
		#for modifier_name in modifier:
			#info += "\n  %s: %s" % [modifier_name, modifier[modifier_name]]
	
	return info

# 道具是否可以堆叠
func can_stack() -> bool:
	return stack_size > 1

# 获取稀有度颜色
func get_rarity_color() -> Color:
	match rarity:
		"普通": return Color.WHITE
		"稀有": return Color.CYAN
		"史诗": return Color.MAGENTA
		"传说": return Color.ORANGE
		"神话": return Color.RED
		_: return Color.WHITE
