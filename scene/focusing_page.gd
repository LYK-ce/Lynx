extends Page


#番茄钟相关变量
var is_running = false
var is_focusing = false

@onready var timer :Timer = $ClockTimer
@onready var label :Label = $CenterContainer/VBoxContainer/Label
@onready var button : Button = $CenterContainer/VBoxContainer/HBoxContainer/Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#将信号连接起来
	timer.timeout.connect(On_Second_Tick)
	Start_Focusing()
	pass # Replace with function body.
	

func Update_Display():
	
	@warning_ignore("integer_division")
	
	var m = Global.left_time / 60
	var s = Global.left_time % 60
	label.text = "%02d:%02d" % [m, s]



func Start_Focusing():
	Global.left_time = Global.focus_minutes * 60 + Global.focus_seconds
	Update_Display()
	timer.start()

func On_Second_Tick():

	Global.left_time -= 1
	Update_Display()
	if Global.left_time == 0:
		#先退出，之后改成其他功能
		get_tree().quit()
