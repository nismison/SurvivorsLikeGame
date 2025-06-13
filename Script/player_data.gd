extends Node

var is_dead: bool = false
var current_health: int
var current_armor: int
var max_health: int = 5
var max_armor: int = 3

var weapon: Item = null # 当前武器

var damage: float  # 基础伤害
var damage_modifier: float = 0.0  # 伤害修正
var damage_total: float = 0.0  # 总伤害

var atk_distance: float  # 攻击距离
var atk_distance_modifier: float = 0.0  # 攻击距离修正
var atk_distance_total: float = 0.0  # 总攻击距离

var move_speed: float = 150.0  # 基础移速
var move_speed_modifier: float = 0.0  # 移速修正
var move_speed_total: float  # 总移速

var dash_speed: float  # 基础闪避速度 -> 移动速度 * 2.5
var dash_speed_modifier: float = 0.0  # 闪避速度修正
var dash_speed_total: float  # 总闪避速度

var dash_cd: float = 1  # 基础闪避CD(单位 秒)
var dash_cd_modifier: float = 0.0  # 闪避CD修正
var dash_cd_total: float  # 总闪避CD

var attack_speed: float  # 基础攻速
var attack_speed_modifier: float = 2.0  # 攻速修正
var attack_speed_total: float  # 总攻速

var bullet_count: int = 1  # 基础子弹数量
var bullet_count_modifier: int = 5  # 子弹数量修正
var bullet_count_total: int  # 总子弹数量
var bullet_spread_degrees: float = 30.0 # 多子弹散射角度

var relic_list: Array[Item] = []  # 当前圣物列表

var random_spread: bool = false  # 道具效果：子弹会不规律散射
var bullet_scale_modifier: float = 0.0  # 子弹大小修正

var exp: float = 0.0  # 人物经验值
var exp_modifier: float = 0.0  # 获取经验值修正
var level: int = 0  # 当前等级

signal inited
signal health_changed
signal player_dead
signal relic_changed
signal weapon_changed
signal camera_zoom_changed
signal exp_changed
signal level_up

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
	# TODO 初始化武器
	weapon = ItemDatabase.get_item_resource(10001)
	damage = weapon.damage
	attack_speed = weapon.attack_speed
	atk_distance = weapon.atk_distance
	
	caculate_all()
	inited.emit()
	

# 重新计算所有属性 (更新属性)
func caculate_all() -> void:
	caculate_damage()
	caculate_move_speed()
	caculate_dash_speed()
	caculate_attack_speed()
	caculate_atk_distance()
	caculate_bullet_count()
	caculate_dash_cd()


# 计算伤害
func caculate_damage() -> void:
	# 总伤害 = 基础伤害 + ( 基础伤害 * 伤害修正 )
	damage_total = damage + damage * damage_modifier


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


# 计算闪避CD
func caculate_dash_cd() -> void:
	# 总闪避CD = 基础闪避CD + ( 基础闪避CD * 闪避CD修正 )
	dash_cd_total = dash_cd + dash_cd * dash_cd_modifier


# 计算攻击速度
func caculate_attack_speed() -> void:
	# 总攻速 = 基础攻速 + ( 基础攻速 * 攻速修正 )
	attack_speed_total = attack_speed + attack_speed * attack_speed_modifier


# 计算攻击距离
func caculate_atk_distance() -> void:
	# 攻击距离 = 基础攻击距离 + ( 基础攻击距离 * 攻击距离修正 )
	atk_distance_total = atk_distance + atk_distance * atk_distance_modifier


# 计算子弹数量
func caculate_bullet_count() -> void:
	# 子弹数量 = 基础子弹数量 + 子弹数量修正
	bullet_count_total = bullet_count + bullet_count_modifier


# 传入物品自动计算属性加成
func caculate_modifier(item: Item) -> void:
	if item.modifier.is_empty(): return
	
	for modifier_name in item.modifier:
		var modifier_value = item.modifier[modifier_name]
		
		if modifier_name == "dash_speed":
			dash_speed_modifier += modifier_value
		elif modifier_name == "dash_cd":
			dash_cd_modifier += modifier_value
		elif modifier_name == "random_spread":
			random_spread = true
	
	caculate_all()

# 新增携带圣物
func relic_add(item: Item) -> void:
	relic_list.append(item)
	caculate_modifier(item)
	relic_changed.emit()


# 切换武器
func switch_weapon(weapon_id: int) -> void:
	var old_weapon = weapon  # 记录原先的武器，如果之前的武器有属性加成，在下面减掉
	weapon = ItemDatabase.get_item_resource(weapon_id)
	attack_speed = weapon.attack_speed
	damage = weapon.damage
	atk_distance = weapon.atk_distance
	
	caculate_all()
	weapon_changed.emit()


# 人物获得经验值
func got_exp(exp_value: float) -> void:
	# 当前经验值 = 当前经验值 + ( 获得的经验值 * ( 1 + 经验值修正 ) )
	exp = exp + exp_value * ( 1 + exp_modifier )
	exp_changed.emit()
	
	var old_level = level
	level = LevelManager.get_current_level(exp)
	
	if level > old_level:
		level_up.emit()


func zoom_camera(zoom_value: float) -> void:
	camera_zoom_changed.emit(zoom_value)
