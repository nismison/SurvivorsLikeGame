extends Node2D
class_name DropItem

@onready var drop_item_area: Area2D = $DropItemArea
@onready var drop_item_sprite: Sprite2D = $DropItemArea/DropItemSprite

@export var item_info_panel_scene: PackedScene = null
@export var pickup_item_fx_scene: PackedScene = null

var item_info_panel: Node = null
var drop_item: Item = null  # 掉落物品对象，怪物死亡后随机生成，并在add_child之前赋值
var is_on_item: bool = false  # 是否碰到掉落物


func _ready() -> void:
	# 修改掉落物贴图
	drop_item_sprite.texture = drop_item.icon
	# 修改尺寸，防止掉落物贴图过大
	var width = drop_item_sprite.get_rect().size.x
	if width > 24:
		var scale_factor = 24 / width
		drop_item_sprite.scale = Vector2(scale_factor, scale_factor)
	
	drop_item_area.body_entered.connect(_on_body_entered)
	drop_item_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_on_item = true
		
		item_info_panel = item_info_panel_scene.instantiate()
		item_info_panel.item = drop_item
		
		# 先添加到场景树中，这样才能获取到面板的尺寸
		get_tree().get_root().add_child(item_info_panel)

		# 等待一帧让面板完成布局计算
		await get_tree().process_frame

		# 计算面板应该显示的位置（掉落物上方居中）
		var panel_size = item_info_panel.size
		var target_position = self.global_position
		target_position.x -= panel_size.x / 2  # 水平居中
		target_position.y -= panel_size.y + 15  # 在掉落物上方，留10像素间距

		item_info_panel.global_position = target_position
	
	
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_on_item = false
		if item_info_panel != null:
			item_info_panel.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# 交互
	if event.is_action_pressed("action"):
		if not is_on_item: return
		
		if drop_item.item_type == "圣物":
			PlayerData.relic_add(drop_item)
		elif drop_item.item_type == "武器":
			PlayerData.switch_weapon(drop_item.id)
		
		var pickup_item_fx = pickup_item_fx_scene.instantiate()
		pickup_item_fx.global_position.x = global_position.x
		pickup_item_fx.global_position.y = global_position.y - 15
		
		get_tree().get_root().add_child(pickup_item_fx)
		queue_free()
