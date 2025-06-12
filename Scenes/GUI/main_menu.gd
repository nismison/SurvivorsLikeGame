extends Node

@onready var start_btn: Button = $Panel/VBoxContainer/MenuButtons/VBoxContainer/StartBtn
@onready var exit_btn: Button = $Panel/VBoxContainer/MenuButtons/VBoxContainer/ExitBtn


func _ready() -> void:
	start_btn.pressed.connect(_on_game_start)
	exit_btn.pressed.connect(_on_game_exit)


func _on_game_start() -> void:
	SceneManager.change_scene("res://Scenes/main.tscn", { "pattern": "circle" })

func _on_game_exit() -> void:
	get_tree().quit() # 关闭游戏
