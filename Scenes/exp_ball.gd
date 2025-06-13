extends Node2D

@onready var suction_area: Area2D = $SuctionArea
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var fly_to_player: bool = false


func _ready() -> void:
	suction_area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if fly_to_player:
		var to_player = player.global_position - global_position
		if to_player.length() > 5:
			var direction = to_player.normalized()
			var target_position = position + direction * 20  # 每次走 20 像素，可以改为其他值
			
			var tween = create_tween()
			tween.tween_property(self, "position", target_position, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			PlayerData.got_exp(5)
			queue_free()


func _on_body_entered(player: Node2D) -> void:
	if not player.is_in_group("player"): return
	
	fly_to_player = true
