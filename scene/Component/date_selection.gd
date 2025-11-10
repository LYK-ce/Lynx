'''
这个组件是在待办当中用于选择日期的组件。通过选择年，月，日。然后提供一个方法，以Unix时间戳的形式返回选定的日期。
'''
extends Control
class_name Date_Selection

@onready var year_button = $VBoxContainer/HBoxContainer/YearButton
@onready var month_button = $VBoxContainer/HBoxContainer/MonthButton
@onready var day_button = $VBoxContainer/HBoxContainer/DayButton
@onready var hour_spin_box = $VBoxContainer/HBoxContainer2/HourSpinBox
@onready var minute_spin_box = $VBoxContainer/HBoxContainer2/MinuteSpinBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#当ready之后，先初始化可选项。
	#首先获取当前的Unix时间戳
	var now_timestamp = Time.get_unix_time_from_system()
	pass
