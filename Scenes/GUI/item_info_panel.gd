extends MarginContainer

@onready var item_name_label: Label = $ItemNameContainer/ItemNameContainer/ItemNameLabel
@onready var item_icon_rect: TextureRect = $ItemInfoContainer/VBoxContainer/ItemIconContainer/ItemIcon
@onready var item_type_label: Label = $ItemInfoContainer/VBoxContainer/HBoxContainer/ItemTypeLabel
@onready var item_quality_label: Label = $ItemInfoContainer/VBoxContainer/HBoxContainer/ItemQualityLabel
@onready var item_describe_label: Label = $ItemInfoContainer/VBoxContainer/ItemDescribeLabel

var item_name: String = "item_name"
var item_describe: String = "item_describe"
var item_icon: Texture2D = null
var item_type: String = "item_type"
var item_quality: String = "item_quality"
var item_quality_color: Color = Color(1, 1, 1, 1)

func _ready() -> void:
	item_icon_rect.texture = item_icon
	item_name_label.text = item_name
	item_type_label.text = item_type
	item_quality_label.text = item_quality
	item_quality_label.add_theme_color_override("font_color", item_quality_color)
	item_describe_label.text = item_describe
	
