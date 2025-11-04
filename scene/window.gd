extends Window

var dragging   = false
var click_pos  = Vector2()          # 鼠标在屏幕上的按下点
var orig_pos   = Vector2()          # 窗口原始位置


@onready var anim :AnimatedSprite2D = $AnimatedSprite2D
signal action(_next_state)

#右键弹出菜单
@onready var menu : PopupMenu = $PopupMenu

#与其他组件的交互
@export var HOST := "127.0.0.1"
@export var PORT := 23333
var client := HTTPClient.new()

func _ready() -> void:
	#上来之后先播放动画
	self.action.connect(anim.Play_Anim)
	self.action.emit(Global_Parameters.State.Idle)
	
	menu.id_pressed.connect(_on_menu_selected)
	
	var err := client.connect_to_host(HOST, PORT)
	if err != OK:
		push_error("外部管道未启动")

func _input(event):     
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		# 在屏幕坐标弹出
		menu.position = DisplayServer.mouse_get_position()
		menu.popup()               # 全局输入
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 只有鼠标在窗口内才启动拖动
			var mp := DisplayServer.mouse_get_position()
			var rect := Rect2(position, size)
			if rect.has_point(mp):
				dragging  = true
				action.emit(Global_Parameters.State.Drag)
				click_pos = mp
				orig_pos  = position
		else:
			dragging = false
			action.emit(Global_Parameters.State.Idle)

	elif event is InputEventMouseMotion and dragging:
		# 计算屏幕位移，直接改窗口位置
		var mp := DisplayServer.mouse_get_position()
		position = orig_pos + mp - click_pos


func _on_menu_selected(id: int) -> void:
	match id:
		0: 
			print('button1 pressed')
			send('daiban')
		1: print('button2 pressed')
		
		#暂时先什么都不做
		10: pass
			#get_tree().quit()

func send(cmd: String) -> void:
	if client.get_status() != HTTPClient.STATUS_CONNECTED:
		client.connect_to_host(HOST, PORT)
	client.request(HTTPClient.METHOD_POST, "/",
			["Content-Type: application/json"], JSON.stringify({"cmd":cmd}))
