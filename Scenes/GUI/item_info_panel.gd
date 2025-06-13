extends MarginContainer

@onready var background_container: MarginContainer = $BackgroundContainer
@onready var item_name_container: MarginContainer = $ItemNameContainer
@onready var item_info_container: MarginContainer = $ItemInfoContainer
@onready var selection: MarginContainer = $Selection
@onready var selection_button: Button = $Selection/SelectionButton


@onready var item_name_label: Label = $ItemNameContainer/ItemNameContainer/ItemNameLabel
@onready var item_icon_rect: TextureRect = $ItemInfoContainer/VBoxContainer/ItemIconContainer/ItemIcon
@onready var item_type_label: Label = $ItemInfoContainer/VBoxContainer/HBoxContainer/ItemTypeLabel
@onready var item_quality_label: Label = $ItemInfoContainer/VBoxContainer/HBoxContainer/ItemQualityLabel
@onready var item_describe_label: Label = $ItemInfoContainer/VBoxContainer/ItemDescribeLabel
@onready var tool_tip_container: MarginContainer = $ItemInfoContainer/VBoxContainer/ToolTipContainer

var item: Item = null
var show_tooltip: bool = true
var mouse_hover_enable: bool = false  # 开启鼠标悬停效果

func _ready() -> void:
	item_icon_rect.texture = item.icon
	item_name_label.text = item.name
	item_type_label.text = item.item_type
	item_quality_label.text = item.rarity
	item_quality_label.add_theme_color_override("font_color", item.get_rarity_color())
	item_describe_label.text = item.description
	
	tool_tip_container.visible = show_tooltip
	
	# 升级奖励
	if mouse_hover_enable:
		var rect_size = self.size
		# 将锚点设置为中心
		anchor_left = 0.5
		anchor_top = 0.5
		anchor_right = 0.5
		anchor_bottom = 0.5
		# 将中心点作为枢轴点
		pivot_offset = rect_size / 2
		
		tool_tip_container.visible = false
		size.x += 30
		
		background_container.add_theme_constant_override("margin_top", 10)
		background_container.add_theme_constant_override("margin_left", 10)
		background_container.add_theme_constant_override("margin_right", 10)
		background_container.add_theme_constant_override("margin_bottom", 10)
		
		item_name_container.add_theme_constant_override("margin_top", 5)
		
		item_info_container.add_theme_constant_override("margin_top", 20)
		item_info_container.add_theme_constant_override("margin_left", 20)
		item_info_container.add_theme_constant_override("margin_right", 20)
		item_info_container.add_theme_constant_override("margin_bottom", 20)
		
		mouse_entered.connect(_on_mouse_hover)
		mouse_exited.connect(_on_mouse_exited)
		selection_button.pressed.connect(_on_pressed)


func _on_mouse_hover() -> void:
	selection.visible = true
	
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)


func _on_mouse_exited() -> void:
	selection.visible = false
	
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)


func _on_pressed() -> void:
	print("当前选择奖励：%s" % item.name)
	PlayerData.relic_add(item)
