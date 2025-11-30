extends Window
class_name Pet

#记录一下当前宠物的状态。感觉还是用一个状态机的方式来实现更好一些。
var last_state : Global.State = Global.State.Undefined
var state : Global.State = Global.State.Idle
var is_running  :bool = false
var is_dragging :bool = false
var is_noticing :bool = false
#处在working状态时只接受通知
var is_sleeping : bool = false

var click_pos  = Vector2()          # 鼠标在屏幕上的按下点
var orig_pos   = Vector2()          # 窗口原始位置

var tween : Tween

@onready var anim :AnimatedSprite2D = $AnimatedSprite2D


#右键弹出菜单
@onready var menu : PopupMenu = $PopupMenu

#是否启用WebSocket
@export var web_socket_enable : bool = true
##与其他组件的交互
#@export var HOST := "10.100.73.11"
#@export var PORT := 8787
#var client := HTTPClient.new()

#状态转移函数
#宠物心情值相关
var mood : int = 100
@onready var mood_bar : ProgressBar = $Mood_bar
#宠物商店相关
var coin : int = 0
#这里实在懒得用信号了，先这样设计吧
@onready var store = $Store

func Try_Enter_State(_next_state : Global.State):
	#所有特殊状态在结束时都会尝试转移到Idle状态当中,如果之前是处在其他状态当中，那么就恢复到当前状态中
	if _next_state == Global.State.Idle:
		if is_sleeping == true:
			_next_state = Global.State.Sleep
		if is_dragging == true:
			_next_state = Global.State.Drag
		
	#根据当前状态判断是否需要进入下一个状态当中
	match state:
		Global.State.Idle:#任意进入其他状态
			pass
		Global.State.Run_Left:#任意进入其他状态
			if tween != null and tween.is_running():
				tween.kill()
			pass
		Global.State.Run_Right:#任意进入其他状态
			if tween != null and tween.is_running():
				tween.kill()
			pass
		Global.State.Drag:#只能进入通知状态
			if is_dragging == true:	
				if _next_state == Global.State.Notice:
					pass
				else:
					return
					
		Global.State.Sleep:#只能进入drag状态和noticing状态
			if _next_state == Global.State.Drag:
				pass
			elif _next_state == Global.State.Notice:
				pass
			else:
				return
		Global.State.Notice:#只要还处在is noticing状态当中，不能进入其他状态
			if is_noticing == true:
				return
		Global.State.Pat:#不会进入run状态
			if _next_state == Global.State.Run_Left or _next_state == Global.State.Run_Right:
				return
		Global.State.Dead:#不能进入任何状态中
			return
			
	#在更新状态之前，我们需要进行一下判断
	#如果是Idle状态，那么就随意进入一个新的状态好了
	#if _next_state != Global.State.Run_Left or _next_state != Global.State.Run_Right:
		#if tween != null and tween.is_running():
				#tween.kill()
	#if state == Global.State.Notice:
		#if last_state == Global.State.Sleep:
			#_next_state = Global.State.Sleep
			#last_state = Global.State.Undefined
	##如果是在睡眠状态，那么就需要根据下一个进入的状态来进行改动
	#elif state == Global.State.Sleep:
		##只有下一个状态是Idle状态时或者通知状态时，它才进入到下一个状态当中，否则拒绝改变状态
		#if  _next_state == Global.State.Notice:
			#pass
		#else:
			#return
	#
	##按理说每一个状态应该都有属于自己的状态转移函数，但是这里为了方便起见，就先放到一块了
	#if _next_state == Global.State.Pat:
		#print('state pat')
		##只有处在Idel状态才能进入pat状态
		#if state != Global.State.Idle:
			#return
		
		
	#更新新的状态，然后触发全局总线的信号。
	state = _next_state
	EventBus.sig_state_change.emit(_next_state)

func _ready() -> void:
	#我们现在采用了全局总线的信号通知方式，因此与全局总线进行通信
	EventBus.sig_request_state_change.connect(Try_Enter_State)
	Try_Enter_State(Global.State.Idle)

	menu.id_pressed.connect(_on_menu_selected)
	
	#一开始要显示在右下角
	var screen := DisplayServer.screen_get_size()
	self.position = Vector2(screen.x-self.size.x, screen.y-self.size.y)
	
	if Load():
		pass
	else:
		Set_Mood(100)
		print(mood)
		coin = 0
		Update()
	
	store.Set_Coin(coin)
	store.Change_Coin_Value(10)



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
				is_dragging = true
		else:
			is_dragging = false
			print('try to enter idle')
			Try_Enter_State(Global.State.Idle)


	elif event is InputEventMouseMotion  and is_dragging == true:
		# 计算屏幕位移，直接改窗口位置
		var mp := DisplayServer.mouse_get_position()
		position = orig_pos + mp - click_pos

func _on_menu_selected(id: int) -> void:
	match id:
		0: 
			var data = {
				  "type": "call",
				  "body": {
					"id": "7",
					"method": "window.show"
				  }
				}
			#转换成json字符串
			var json_string = JSON.stringify(data)
			EventBus.sig_order.emit(json_string)
		
		1: 
			var data = {
				  "type": "call",
				  "body": {
					"id": "7",
					"method": "window.show"
				  }
				}
				#转换成json字符串
			var json_string = JSON.stringify(data)
			EventBus.sig_order.emit(json_string)
			
		4:#打开商店系统
			EventBus.sig_open_store.emit()
		#暂时先什么都不做
		10: pass
		11:
			EventBus.sig_update_status.emit()
			
			await get_tree().create_timer(0.1).timeout
			get_tree().quit()

	

#一个计时功能，时间到后，给小猫往左往右一个随机的位置，然后让它跑过去。
func _on_timer_timeout() -> void:
	#只有在Idle状态下才会执行此操作
	if state == Global.State.Idle:
		call_deferred("Random_Move")
	#其他状态下就完全不动了
	else:
		return

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


#失去焦点时触发此函数
func _on_focus_exited() -> void:
	menu.hide()
 

#增加互动的功能，摸头的具体实现位置
func _on_pat_mouse_entered() -> void:
	print('mouse entered')
	Try_Enter_State(Global.State.Pat)
	#todo
	#这里准备尝试进入pat状态
	pass # Replace with function body.

func _on_pat_mouse_exited() -> void:
	print('mouse exited')
	#这里尝试退出Pat状态
	#如果处于pat状态时我们才能退出Pat状态
	if state == Global.State.Pat:
		Try_Enter_State(Global.State.Idle)
	#如果不处在Pat状态就不用管了
	else:
		return
	pass # Replace with function body.


#和mood相关的函数
func Check_Mood():
	mood = clamp(mood, Global.Mood_Min, Global.Mood_Max)
	#心情值降为0就进入死亡状态
	mood_bar.value = mood
	if mood == 0:
		Try_Enter_State(Global.State.Dead)
	
func Set_Mood(_value):
	mood = _value
	Check_Mood()

func Change_Mood(_value):
	mood += _value
	Check_Mood()

# 文件保存与读取相关
#每次心情值和coin值发生变化就调用此函数进行更新
func Update():
	var save_data:GameSave = null
	if FileAccess.file_exists('save.tres'):
		save_data = load('save.tres') as GameSave
	else:
		save_data = GameSave.new()
	save_data.mood = mood
	save_data.coin = coin
	print(save_data.mood)
	ResourceSaver.save(save_data,'save.tres')

func Load():
	var save_data : GameSave = null
	if FileAccess.file_exists('save.tres'):
		save_data = load('save.tres') as GameSave
		mood = save_data.mood
		coin = save_data.coin
		return true
	else:
		return false
