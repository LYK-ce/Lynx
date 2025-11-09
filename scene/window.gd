extends Window
class_name Pet

var dragging   = false
var click_pos  = Vector2()          # 鼠标在屏幕上的按下点
var orig_pos   = Vector2()          # 窗口原始位置


@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
signal action(_next_state)
signal command(_order)

#右键弹出菜单
@onready var menu : PopupMenu = $PopupMenu

#与其他组件的交互
@export var HOST := "127.0.0.1"
@export var PORT := 8787
var client := HTTPClient.new()



func _ready() -> void:
	#上来之后先播放动画
	self.action.connect(anim.Play_Anim)
	self.action.emit(Global.State.Idle)
	
	menu.id_pressed.connect(_on_menu_selected)
	
	var err := client.connect_to_host(HOST, PORT)
	if err != OK:
		push_error("外部管道未启动")

func _input(event):     
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# 在屏幕坐标弹出
		menu.position = DisplayServer.mouse_get_position()
		menu.popup()          
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 只有鼠标在窗口内才启动拖动
			var mp := DisplayServer.mouse_get_position()
			var rect := Rect2(position, size)
			if rect.has_point(mp):
				dragging  = true
				action.emit(Global.State.Drag)
				click_pos = mp
				orig_pos  = position
		else:
			dragging = false
			action.emit(Global.State.Idle)

	elif event is InputEventMouseMotion and dragging:
		# 计算屏幕位移，直接改窗口位置
		var mp := DisplayServer.mouse_get_position()
		position = orig_pos + mp - click_pos


func _on_menu_selected(id: int) -> void:
	match id:
		0: 
			var data = {
				  "type": "call",
				  "body": 
					{
						"id": "123",
						"method": "create_todo",
						"params": 
						{
					  		"title": "新待办事项"
						}
  					}
			}
			#转换成json字符串
			var json_string = JSON.stringify(data)
			command.emit(json_string)
			Take_Action(Global.State.Sleep)
		1: print('button2 pressed')
		
		#暂时先什么都不做
		10: pass
			#get_tree().quit()
func Take_Action(_next_state):
	print('take action',_next_state)
	action.emit(_next_state)
	
#func send(cmd: String) -> void:
	#if client.get_status() != HTTPClient.STATUS_CONNECTED:
		#client.connect_to_host(HOST, PORT)
	#client.request(HTTPClient.METHOD_POST, "/",
			#["Content-Type: application/json"], JSON.stringify({"cmd":cmd}))

#一个计时功能，时间到后，给小猫往左往右一个随机的位置，然后让它跑过去。
func _on_timer_timeout() -> void:
	#先获取屏幕整个的尺寸
	var screen_width = DisplayServer.screen_get_size().x

	var window_size = self.size
	var current_pos = self.position
	
	var move_range = 200
	var random_offset = randi_range(-move_range, move_range)
	
	var target_x = current_pos.x + random_offset
	
	# 确保目标位置在屏幕边界内
	target_x = clamp(target_x, 0, screen_width - window_size.x)
	print(target_x)
	var target_pos = Vector2(target_x, current_pos.y)
	position.x = target_x
	#var tween = create_tween()
	#tween.tween_property(self, "position", target_pos,0.5)
	#tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_callback(func(): print("移动完成，新位置:", self.position))
