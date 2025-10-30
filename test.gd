extends Node2D

var drag_offset := Vector2()
var is_dragging := false

func _ready() -> void:
	# 让 TextureRect 把事件传上来
	$TextureRect.gui_input.connect(_on_pet_click)
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TOOL, true, 0)

# 只接收“点在宠物实体像素上”的事件
func _on_pet_click(event: InputEvent) -> void:
	# 左键按下
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed and !mb.is_echo():
				is_dragging = true
				drag_offset = DisplayServer.mouse_get_position() - DisplayServer.window_get_position()
			else:
				is_dragging = false

	# 拖动过程中移动窗口
	if is_dragging and event is InputEventMouseMotion:
		var new_pos = DisplayServer.mouse_get_position() - Vector2i(drag_offset)
		DisplayServer.window_set_position(Vector2i(new_pos))
		# 让事件不再继续传递
		get_viewport().set_input_as_handled()
