# LevelManager.gd - Autoload脚本
extends Node

var levels_data: Dictionary = {}
var json_path: String = "res://data/levels.json"

func _ready():
	load_levels_data()

# 加载JSON数据
func load_levels_data():
	if not FileAccess.file_exists(json_path):
		print("错误: 找不到等级数据文件:", json_path)
		return
		
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("错误: 无法打开等级数据文件:", json_path)
		return
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("错误: JSON解析失败，错误代码:", parse_result)
		return
		
	levels_data = json.data
	print("等级数据加载成功，共", levels_data.size(), "个等级")

# 获取升级到指定等级所需的经验值
func get_level_required_exp(level: int) -> float:
	var level_key = "level_" + str(level)
	if level_key in levels_data:
		return float(levels_data[level_key].get("need_exp", 0.0))
	else:
		print("警告: 找不到等级数据: 等级", level)
		return 0.0

# 根据当前经验值计算角色等级
func get_current_level(current_exp: float) -> int:
	var current_level = 0
	
	# 从level_1开始检查，level_0是初始等级
	for i in range(1, get_max_level() + 1):
		var required_exp = get_level_required_exp(i)
		if current_exp >= required_exp:
			current_level = i
		else:
			break
	
	return current_level

# 计算升级到下一等级还需要多少经验值
func get_exp_to_next_level(current_exp: float) -> float:
	var current_level = get_current_level(current_exp)
	var next_level = current_level + 1
	var next_level_exp = get_level_required_exp(next_level)
	
	# 如果已经是最高等级
	if next_level_exp == 0.0:
		return 0.0
	
	return next_level_exp - current_exp

# 获取当前等级的经验值进度（0.0-1.0）
func get_level_progress(current_exp: float) -> float:
	var current_level = get_current_level(current_exp)
	var next_level = current_level + 1
	
	# 如果已经是最高等级
	if not has_level(next_level):
		return 1.0
	
	# 获取当前等级的起始经验值（上一等级的need_exp，如果是level_0则为0）
	var current_level_start_exp = 0.0
	if current_level > 0:
		current_level_start_exp = get_level_required_exp(current_level)
	
	# 获取下一等级需要的经验值
	var next_level_exp = get_level_required_exp(next_level)
	
	# 计算当前等级区间内的进度
	var exp_in_current_level = current_exp - current_level_start_exp
	var exp_needed_for_next = next_level_exp - current_level_start_exp
	
	return exp_in_current_level / exp_needed_for_next

# 获取最高等级
func get_max_level() -> int:
	var max_level = 0
	for level_key in levels_data.keys():
		var level_num_str = level_key.replace("level_", "")
		var level_num = level_num_str.to_int()
		if level_num > max_level:
			max_level = level_num
	return max_level

# 检查是否可以升级
func can_level_up(current_exp: float) -> bool:
	var current_level = get_current_level(current_exp)
	var next_level = current_level + 1
	
	# 检查下一等级是否存在
	if not has_level(next_level):
		return false
		
	var next_level_exp = get_level_required_exp(next_level)
	return current_exp >= next_level_exp

# 获取指定等级的完整数据
func get_level_data(level: int) -> Dictionary:
	var level_key = "level_" + str(level)
	if level_key in levels_data:
		return levels_data[level_key]
	else:
		print("警告: 找不到等级数据: 等级", level)
		return {}

# 获取所有等级数据
func get_all_levels() -> Dictionary:
	return levels_data

# 检查等级是否存在
func has_level(level: int) -> bool:
	var level_key = "level_" + str(level)
	return level_key in levels_data

# 获取等级数量
func get_level_count() -> int:
	return levels_data.size()

# 重新加载数据（用于开发阶段热更新）
func reload_data():
	levels_data.clear()
	load_levels_data()

# 获取等级信息摘要（用于调试）
func get_level_info(current_exp: float) -> Dictionary:
	var current_level = get_current_level(current_exp)
	var next_level = current_level + 1
	var info = {
		"current_level": current_level,
		"current_exp": current_exp,
		"exp_to_next": get_exp_to_next_level(current_exp),
		"progress": get_level_progress(current_exp),
		"max_level": get_max_level(),
		"is_max_level": current_level >= get_max_level()
	}
	return info
