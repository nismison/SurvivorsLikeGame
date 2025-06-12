extends Area2D

@onready var teleport_stone: AnimatedSprite2D = $TeleportStone
@onready var teleport_stone_active: AnimatedSprite2D = $TeleportStoneActive

var ready_to_teleport: bool = false
var is_teleporting: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"): return
	
	ready_to_teleport = true
	PlayerData.zoom_camera(5)
	print("玩家进入传送阵")


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"): return
	
	ready_to_teleport = false
	PlayerData.zoom_camera(2.5)
	print("玩家离开传送阵")


func _unhandled_input(event: InputEvent) -> void:
	# 交互
	if event.is_action_pressed("action"):
		if not ready_to_teleport or is_teleporting: return
		
		is_teleporting = true
		teleport_stone.queue_free()
		teleport_stone_active.visible = true
		teleport_stone_active.play("default")
		await teleport_stone_active.animation_finished
		teleport_stone_active.queue_free()
		print("传送！")
