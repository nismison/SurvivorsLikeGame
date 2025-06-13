extends Control

@onready var h_box_container: HBoxContainer = $VBoxContainer/HBoxContainer


func _ready() -> void:
	genarate_drop_item()


func genarate_drop_item() -> void:
	# 生成掉落物
	for i in 3:
		var all_relic_items = ItemDatabase.get_all_item_ids()

		var array_size = all_relic_items.size()
		var random_index = randi() % array_size
		var drop_item_id = all_relic_items[random_index]
		var relic_object = ItemDatabase.get_item_resource(drop_item_id)
		
		var item_info_panel = preload("res://Scenes/GUI/item_info_panel.tscn").instantiate().duplicate()
		item_info_panel.mouse_hover_enable = true
		item_info_panel.item = relic_object
		
		#var drop_item_scene = preload("res://Scenes/drop_item.tscn")
		#var drop_item_instant = drop_item_scene.instantiate()
		#drop_item_instant.drop_item = relic_object
		#drop_item_instant.global_position = global_position
		
		h_box_container.add_theme_constant_override("separation", 20)
		h_box_container.call_deferred("add_child", item_info_panel)
