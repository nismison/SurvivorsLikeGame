extends EnemyBase

@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/AttackShape
@onready var attack_cd_timer: Timer = $AttackCDTimer
@onready var hurt_area: Area2D = $HurtArea

var ready_to_attack: bool


# 初始化敌人数据
func init_enemy() -> void:
	enemy_sprite = $AnimatedSprite2D
	min_distance_to_player = 20
	ready_to_attack = true
	attack_shape.disabled = true
	attack_cd_timer.timeout.connect(_on_attack_cd_timeout)
	# 攻击判定
	attack_area.area_entered.connect(_on_attack_area_entered)
	# 受击判定
	hurt_area.area_entered.connect(_on_hurt_area_entered)


func handle_behavior(delta: float):
	if current_state == EnemyState.ATTACKING:
		return
		
	var to_player = player.global_position - global_position
	
	# 距离玩家超过距离
	if to_player.length() > min_distance_to_player:
		var move_dir = (player.global_position - global_position).normalized()
		velocity = move_dir * enemy_speed
		current_state = EnemyState.MOVING
		move_and_slide()
		
		enemy_sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		current_state = EnemyState.IDLE
		enemy_sprite.play("idle")
		
		if ready_to_attack and not PlayerData.is_dead:
			start_attack()
	
	# 处理翻转
	if to_player.x < -1:
		attack_area.scale.x = -1
		enemy_sprite.flip_h = true  # 向左
	elif to_player.x > 1:
		attack_area.scale.x = 1
		enemy_sprite.flip_h = false  # 向右


func start_attack() -> void:
	# 开始攻击，进入cd
	ready_to_attack = false
	attack_cd_timer.start()
	
	current_state = EnemyState.ATTACKING
	
	# 攻击动画
	attack_shape.disabled = false
	enemy_sprite.play("attack")
	await enemy_sprite.animation_finished
	current_state = EnemyState.IDLE
	attack_shape.disabled = true


# 攻击cd结束
func _on_attack_cd_timeout() -> void:
	ready_to_attack = true

# 攻击到目标
func _on_attack_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("player"):
		area.owner.hurted(attack_damage)
	

# 受击
func _on_hurt_area_entered(bullet: Area2D) -> void:
	if bullet.is_in_group("bullet"):
		take_damage()
		bullet.spawn_explosion()
