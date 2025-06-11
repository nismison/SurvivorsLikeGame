extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer


func _ready():
	PlayerData.init_player_data()  # 初始化人物数据
	draw_relic_ui()
	PlayerData.relic_changed.connect(on_relic_changed)


func on_relic_changed() -> void:
	clean_relic_ui()
	draw_relic_ui()
	
	
func clean_relic_ui() -> void:
	for i in len(PlayerData.relic_list) - 1:
		h_box_container.get_child(i).queue_free()
		

func draw_relic_ui() -> void:
	for item: Item in PlayerData.relic_list:
		var texture_rect := create_relic_icon(item.icon)
		h_box_container.add_child(texture_rect)
	

func create_relic_icon(texture: Texture2D) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	return texture_rect
