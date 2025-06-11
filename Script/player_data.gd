extends Node

var is_dead: bool = false
var current_health: int
var current_armor: int
var max_health: int = 5
var max_armor: int = 3

var weapon: String = "fazhang" # 当前武器

var atk_distance: float = 200  # 攻击距离
var atk_distance_modifier: float = 0.0  # 攻击距离修正
var atk_distance_total: float = 0.0  # 总攻击距离

var move_speed: float = 150.0  # 基础移速
var move_speed_modifier: float = 0.0  # 移速修正
var move_speed_total: float  # 总移速

var dash_speed: float  # 基础闪避速度 -> 移动速度 * 2.5
var dash_speed_modifier: float = 0.0  # 闪避速度修正
var dash_speed_total: float  # 总闪避速度

var attack_speed: float = 5.0  # 基础攻速
var attack_speed_modifier: float = 0.0  # 攻速修正
var attack_speed_total: float  # 总攻速

var relic_list: Array[Item] = []  # 当前圣物列表


#var player_level: int = 1
#var player_exp: int = 0
#var player_inventory: Array = []
#var player_attack_speed: int = 2

signal health_changed
signal player_dead
signal relic_changed
#signal level_up(new_level)

func take_player_damage() -> void:
	if current_armor > 0:
		current_armor = max(0, current_armor - 1)
	else:
		current_health = max(0, current_health - 1)
	
	health_changed.emit()
	
	if current_armor <= 0 and current_health <= 0:
		is_dead = true
		player_dead.emit()

func init_player_data() -> void:
	is_dead = false
	current_health = max_health
	current_armor = max_armor
	caculate_move_speed()
	caculate_dash_speed()
	caculate_attack_speed()
	caculate_atk_distance()


# 计算移动速度
func caculate_move_speed() -> void:
	# 总移速 = 基础移速 + ( 基础移速 * 移速修正 )
	move_speed_total = move_speed + move_speed * move_speed_modifier


# 计算闪避速度
func caculate_dash_speed() -> void:
	# 基础闪避速度 = 基础移速 * 2.5
	# 总闪避速度 = 基础闪避速度 + ( 基础闪避速度 * 闪避速度修正 )
	dash_speed = move_speed * 2.5
	dash_speed_total = dash_speed + dash_speed * dash_speed_modifier


# 计算攻击速度
func caculate_attack_speed() -> void:
	# 总攻速 = 基础攻速 + ( 基础攻速 * 攻速修正 )
	attack_speed_total = attack_speed + attack_speed * attack_speed_modifier


# 计算攻击速度
func caculate_atk_distance() -> void:
	# 攻击距离 = 基础攻击距离 + ( 基础攻击距离 * 攻击距离修正 )
	atk_distance_total = atk_distance + atk_distance * atk_distance_modifier


func relic_add(item: Item) -> void:
	relic_list.append(item)
	relic_changed.emit()
