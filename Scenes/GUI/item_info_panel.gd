extends MarginContainer

@onready var item_name_label: Label = $ItemNameContainer/ItemNameContainer/ItemNameLabel
@onready var item_icon_rect: TextureRect = $ItemInfoContainer/VBoxContainer/ItemIconContainer/ItemIcon
@onready var item_type_label: Label = $ItemInfoContainer/VBoxContainer/HBoxContainer/ItemTypeLabel
@onready var item_quality_label: Label = $ItemInfoContainer/VBoxContainer/HBoxContainer/ItemQualityLabel
@onready var item_describe_label: Label = $ItemInfoContainer/VBoxContainer/ItemDescribeLabel
@onready var tool_tip_container: MarginContainer = $ItemInfoContainer/VBoxContainer/ToolTipContainer

var item: Item = null
var show_tooltip: bool = true

func _ready() -> void:
	item_icon_rect.texture = item.icon
	item_name_label.text = item.name
	item_type_label.text = item.item_type
	item_quality_label.text = item.rarity
	item_quality_label.add_theme_color_override("font_color", item.get_rarity_color())
	item_describe_label.text = item.description
	
	tool_tip_container.visible = show_tooltip
	
