extends Node2D

@onready var line = $MoveLine


func _ready() -> void:
	visible = false


func move_line_simple(duration: float = 1):
	visible = true
	line.clear_points()
	line.add_point(Vector2(0, -3))
	line.add_point(Vector2(0, 3))

	# 设置初始位置
	line.position = Vector2(0, 0)
	
	# 创建Tween实例
	var tween = create_tween()

	# 直接移动Line2D节点的position
	tween.tween_property(line, "position", Vector2(30, 0), duration)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	await tween.finished
	visible = false
