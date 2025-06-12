extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer

var item_info_panel: Control


func _ready():
	draw_relic_ui()
	PlayerData.relic_changed.connect(on_relic_changed)


# 圣物列表变更触发
func on_relic_changed() -> void:
	clean_relic_ui()
	draw_relic_ui()
	

# 删除所有圣物UI
func clean_relic_ui() -> void:
	for i in len(PlayerData.relic_list) - 1:
		var node = h_box_container.get_child(i)
		if node:
			node.queue_free()
		

# 绘制当前携带圣物UI
func draw_relic_ui() -> void:
	print("len: %s" % len(PlayerData.relic_list))
	for index in len(PlayerData.relic_list):
		print("index: %s" % index)
		var item: Item = PlayerData.relic_list[index]
		print("Draw Relic Item: %s" % item)
		var texture_rect := create_relic_icon(item.icon)
		texture_rect.mouse_entered.connect(_on_relicui_mouse_entered.bind(item))
		texture_rect.mouse_exited.connect(_on_relicui_mouse_exited.bind(item))
		h_box_container.add_child(texture_rect)
	

func create_relic_icon(texture: Texture2D) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	return texture_rect
	

# 鼠标悬停显示圣物信息
func _on_relicui_mouse_entered(item: Item) -> void:
	item_info_panel = preload("res://Scenes/GUI/item_info_panel.tscn").instantiate()
	item_info_panel.item = item
	item_info_panel.show_tooltip = false
	
	add_child(item_info_panel)
	
	## 等待一帧让面板完成布局计算
	await get_tree().process_frame
#
	# 计算面板应该显示的位置
	var panel_size = item_info_panel.size
	var target_position = get_global_mouse_position()
	target_position.x -= panel_size.x
	target_position.y += 10

	item_info_panel.global_position = target_position
	

# 鼠标移出删除圣物信息
func _on_relicui_mouse_exited(item: Item) -> void:
	item_info_panel.queue_free()
