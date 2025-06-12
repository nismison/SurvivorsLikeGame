extends CharacterBody2D
class_name Player

@export var is_dashing := false
@export var ready_to_dash := true
@export var is_dead := false
@export var god_mode: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cd_timer: Timer = $DashCDTimer
@onready var hurt_sfx: ColorRect = $ScreenSfx/HurtSfx
@onready var camera_2d: Camera2D = $Camera2D
@onready var hurt_area: Area2D = $HurtArea

@onready var weapon_socket = $WeaponSocket

var dash_direction = Vector2.ZERO

# 摄像机缩放
var current_tween: Tween  # 保存当前的Tween引用

var cur_weapon_instance: Node2D  # 当前武器实例


# 缩放到指定值的函数
func zoom_to(target_zoom_value: float, duration: float = 0.3):
	# 停止当前的缩放动画
	if current_tween:
		current_tween.kill()

	# 创建新的Tween
	current_tween = create_tween()

	# 创建缩放动画
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_QUART)
	current_tween.tween_property(camera_2d, "zoom", Vector2(target_zoom_value, target_zoom_value), duration)


func _ready():
	init_weapon()  # 初始化武器场景、绑定挂点
	PlayerData.player_dead.connect(on_player_dead)
	PlayerData.weapon_changed.connect(init_weapon)
	PlayerData.camera_zoom_changed.connect(zoom_to)
	

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	if is_dashing:
		velocity = dash_direction * PlayerData.dash_speed_total
		animated_sprite_2d.play("dash")
	else:
		var move_derection: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = move_derection * PlayerData.move_speed_total
		
		# 控制播放动画
		if velocity.length() > 0:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")
			
	# 控制水平翻转
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0

	move_and_slide()
	

# 初始化武器场景
func init_weapon() -> void:
	if cur_weapon_instance:
		cur_weapon_instance.queue_free()

	var weapon_scene = load(PlayerData.weapon.scene)
	cur_weapon_instance = weapon_scene.instantiate()
	weapon_socket.add_child(cur_weapon_instance)
	#weapon_instance.target_node = weapon_socket  # 设置跟随目标为Socket


func _unhandled_input(event: InputEvent) -> void:
	# 闪避监听
	if event.is_action_pressed("dash") and not is_dashing:
		start_dash()


# 闪避相关函数
func start_dash() -> void:
	if is_dashing or not ready_to_dash:
		return
	
	is_dashing = true
	ready_to_dash = false
	
	var _dash_derection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 冲刺
	dash_direction = _dash_derection.normalized()
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT
	
	# 定时清除冲刺状态
	dash_timer.start()
	await dash_timer.timeout
	is_dashing = false
	
	# 冲刺cd
	dash_cd_timer.start()
	await dash_cd_timer.timeout
	ready_to_dash = true


# 受击
func hurted(damage: float) -> void:
	if is_dead or god_mode: return
	
	PlayerData.take_player_damage()
	hurt_screen_sfx()
	var sprite_material = animated_sprite_2d.material as ShaderMaterial
	sprite_material.set_shader_parameter("flash", true)
	await get_tree().create_timer(0.1).timeout
	sprite_material.set_shader_parameter("flash", false)

# 受击屏闪效果
func hurt_screen_sfx() -> void:
	# 屏闪效果
	get_tree().create_tween().tween_property(hurt_sfx.material, "shader_parameter/opacity", 1.0, 0.1)
	await get_tree().create_timer(0.1).timeout
	get_tree().create_tween().tween_property(hurt_sfx.material, "shader_parameter/opacity", 0.0, 0.1)


func on_player_dead() -> void:
	print("你嘎了")
	zoom_to(5)
	is_dead = true
	animated_sprite_2d.play("dead")
