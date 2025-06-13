extends GPUParticles2D


func _ready() -> void:
	# 配置死亡粒子效果
	setup_death_particles()
	# 初始时不发射粒子
	emitting = false


func setup_death_particles():
	"""配置死亡粒子效果的参数"""
	
	# 创建新的粒子材质
	var material = ParticleProcessMaterial.new()
	
	# === 基本设置 ===
	material.direction = Vector3(0, 0, 0)  # Vector3(0, 1, 0) 向上发射
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 150.0
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	
	# === 重力和阻力 ===
	material.gravity = Vector3(0, 0, 0)  # Vector3(0, 1, 0) 重力向下
	material.linear_accel_min = -10.0
	material.linear_accel_max = 10.0
	
	# === 生命周期和淡出 ===
	material.lifetime_randomness = 0.3
	material.scale_min = 0.5
	material.scale_max = 1.5
	material.scale_over_velocity_min = 0.0
	material.scale_over_velocity_max = 0.0
	
	# === 颜色变化 ===
	# 创建颜色渐变：红色 -> 橙色 -> 透明
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.RED)
	#gradient.add_point(0.3, Color.ORANGE)
	#gradient.add_point(0.7, Color.YELLOW)
	gradient.add_point(1.0, Color.TRANSPARENT)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	
	# === 发射形状 ===
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 10.0
	
	# === 粒子纹理 ===
	# 你可以替换为自定义的粒子纹理
	# material.texture = preload("res://particles/blood_particle.png")
	
	# 应用材质到粒子系统
	process_material = material
	
	# === GPUParticles2D 基本设置 ===
	amount = 200  # 粒子数量
	lifetime = 10.0  # 粒子生存时间
	speed_scale = 1.0
	explosiveness = 1.0  # 一次性爆发所有粒子
	randomness = 0.2
	
	# 设置粒子的绘制顺序
	z_index = 100


func play_death_effect():
	"""播放死亡粒子效果"""
	# 重置粒子系统
	restart()
	emitting = true
	
	# 粒子效果持续时间后停止发射
	await get_tree().create_timer(0.1).timeout
	emitting = false
