extends Control

@onready var h_box_container: HBoxContainer = $VBoxContainer/HBoxContainer


func genarate_drop_item() -> void:
	# TODO 升级奖励
	# 清空奖励
	for child in h_box_container.get_children():
		child.queue_free()
	
	var bonus_count = 4 if PlayerData.level_up_more_bonus else 3
	for i in bonus_count:
		var all_relic_items = ItemDatabase.get_items_by_type("圣物")

		var array_size = all_relic_items.size()
		var random_index = randi() % array_size
		var bonus_item = all_relic_items[random_index]
		
		var item_info_panel = preload("res://Scenes/GUI/item_info_panel.tscn").instantiate().duplicate()
		item_info_panel.mouse_hover_enable = true
		item_info_panel.item = bonus_item
		
		h_box_container.add_theme_constant_override("separation", 20)
		h_box_container.call_deferred("add_child", item_info_panel)
