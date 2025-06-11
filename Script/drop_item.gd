extends Node2D
class_name DropItem

@onready var drop_item_area: Area2D = $DropItemArea

@export var item_info_panel_scene: PackedScene = null

var item_info_panel: Node = null
var drop_item_id: int  # 掉落物品的ID


func _ready() -> void:
	drop_item_area.body_entered.connect(_on_body_entered)
	drop_item_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if item_info_panel_scene == null:
			print("没有设置 item_info_panel 场景")
			return
		
		var item = ItemDatabase.get_item_resource(drop_item_id)
		
		item_info_panel = item_info_panel_scene.instantiate()
		item_info_panel.item_name = item.name
		item_info_panel.item_describe = item.description
		item_info_panel.item_icon = item.icon
		item_info_panel.item_type = item.item_type
		item_info_panel.item_quality = item.rarity
		item_info_panel.item_quality_color = item.get_rarity_color()
		
		# 先添加到场景树中，这样才能获取到面板的尺寸
		get_tree().get_root().add_child(item_info_panel)

		# 等待一帧让面板完成布局计算
		await get_tree().process_frame

		# 计算面板应该显示的位置（掉落物上方居中）
		var panel_size = item_info_panel.size
		var target_position = self.global_position
		target_position.x -= panel_size.x / 2  # 水平居中
		target_position.y -= panel_size.y + 10  # 在掉落物上方，留10像素间距

		item_info_panel.global_position = target_position
	
	
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("玩家离开道具")
		body.zoom_to(3)
		if item_info_panel != null:
			item_info_panel.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# 交互
	if event.is_action_pressed("action"):
		pass
