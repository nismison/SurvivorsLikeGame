extends Node2D

@onready var exp_line: Line2D = $ExpLine

func _ready() -> void:
	PlayerData.exp_changed.connect(_on_exp_changed)


func _on_exp_changed() -> void:
	var viewport_width := get_viewport_rect().size.x
	var progres = LevelManager.get_level_progress(PlayerData.exp)
	exp_line.points[1].x = progres * viewport_width  # 计算经验条长度
