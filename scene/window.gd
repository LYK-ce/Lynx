extends Window
class_name Pet

#记录一下当前宠物的状态。感觉还是用一个状态机的方式来实现更好一些。
var state : Global.State = Global.State.Idle
var speed  = 50

var click_pos  = Vector2()          # 鼠标在屏幕上的按下点
var orig_pos   = Vector2()          # 窗口原始位置

var tween : Tween

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D


#右键弹出菜单
@onready var menu : PopupMenu = $PopupMenu

#与其他组件的交互
@export var HOST := "127.0.0.1"
@export var PORT := 8787
var client := HTTPClient.new()

#现在让我们来实现一个状态机，首先是尝试进入一个新的状态
#整体状态机似乎不用设置的太复杂，毕竟可互动的内容暂时较少。
func Try_Enter_State(_next_state : Global.State):
	#更新新的状态，然后触发全局总线的信号。
	state = _next_state
	EventBus.sig_state_change.emit(_next_state)

func _ready() -> void:
	

	#我们现在采用了全局总线的信号通知方式，因此与全局总线进行通信
	EventBus.sig_request_state_change.connect(Try_Enter_State)
	Try_Enter_State(Global.State.Idle)

	menu.id_pressed.connect(_on_menu_selected)
	
	
	
	#准备与外部进行连接，如果是godot自行组织的话，那么这里就不需要了
	var err := client.connect_to_host(HOST, PORT)
	if err != OK:
		push_error("外部管道未启动")
	#var mainwindow = get_parent().get_parent()
	#mainwindow.visible = false
	self.force_native = false
	



#输入函数，鼠标左键、右键输入
func _input(event):     
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# 在屏幕坐标弹出
		menu.position = DisplayServer.mouse_get_position()
		menu.popup()          
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			#如果tween正在运行当中，那么将其打断
			if tween != null and tween.is_running():
				tween.kill()
			# 只有鼠标在窗口内才启动拖动
			var mp := DisplayServer.mouse_get_position()
			var rect := Rect2(position, size)
			if rect.has_point(mp):
				Try_Enter_State(Global.State.Drag)
				click_pos = mp
				orig_pos  = position
		else:
			Try_Enter_State(Global.State.Idle)


	elif event is InputEventMouseMotion and state == Global.State.Drag:
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
			EventBus.sig_order.emit(json_string)
			Try_Enter_State(Global.State.Sleep)
		1: print('button2 pressed')
		
		#暂时先什么都不做
		10: pass
		11:
			get_tree().quit()

	

#一个计时功能，时间到后，给小猫往左往右一个随机的位置，然后让它跑过去。
func _on_timer_timeout() -> void:
	call_deferred("Random_Move")

#目前的结论是无法使用tween节点来调整window的位置。这也太怪了。
func Random_Move():
	var screen_width = DisplayServer.screen_get_size().x

	var window_size = self.size
	var current_pos = self.position
	
	var move_range = 800
	var min_distance = 200
	var random_offset = randi_range(-move_range, move_range)
	if abs(random_offset) < min_distance:
		random_offset = min_distance
	
	var target_x = current_pos.x + random_offset
	
	# 确保目标位置在屏幕边界内
	target_x = clamp(target_x, 0, screen_width - window_size.x)

	print(target_x)
	var target_pos = Vector2(target_x, current_pos.y)
	#position = target_pos
	tween = create_tween()
	if target_x > current_pos.x:
		EventBus.sig_request_state_change.emit(Global.State.Run_Right)
	else:
		EventBus.sig_request_state_change.emit(Global.State.Run_Left)
	tween.tween_property(self, "position", Vector2i(target_pos),2)
	tween.tween_callback(func(): EventBus.sig_request_state_change.emit(Global.State.Idle))
	tween.play()


	
