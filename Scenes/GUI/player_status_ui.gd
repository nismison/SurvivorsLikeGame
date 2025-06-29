extends Control

@onready var hp_container: HBoxContainer = $VBoxContainer/HPContainer
@onready var armor_container: HBoxContainer = $VBoxContainer/ArmorContainer

var _is_darwing: bool = false


func _ready():
	PlayerData.init_player_data()  # 初始化人物数据
	draw_health_ui()
	PlayerData.health_changed.connect(on_health_changed)


func on_health_changed() -> void:
	clean_health_ui()
	draw_health_ui()
	
	
func clean_health_ui() -> void:
	for node: Node in hp_container.get_children():
		node.queue_free()
		
	for node: Node in armor_container.get_children():
		node.queue_free()


func draw_health_ui() -> void:
	if _is_darwing: return
	
	_is_darwing = true
	for i in PlayerData.current_health:
		var texture_rect := create_icon(Rect2(21, 13, 10, 9))
		hp_container.add_child(texture_rect)
	
	for i in (PlayerData.max_health - PlayerData.current_health):
		var texture_rect := create_icon(Rect2(33, 13, 10, 9))
		hp_container.add_child(texture_rect)
	
	for i in PlayerData.current_armor:
		var texture_rect := create_icon(Rect2(21, 38, 10, 10))
		armor_container.add_child(texture_rect)
	
	for i in (PlayerData.max_armor - PlayerData.current_armor):
		var texture_rect := create_icon(Rect2(33, 38, 10, 10))
		armor_container.add_child(texture_rect)
	
	_is_darwing = false


func create_icon(region: Rect2) -> TextureRect:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = load("res://Assets/GUI/HeartManaUi.png")
	atlas_texture.region = region

	var texture_rect := TextureRect.new()
	texture_rect.texture = atlas_texture
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	return texture_rect
