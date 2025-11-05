extends Page


@onready var button = $CenterContainer/VBoxContainer/HBoxContainer2/Button
@onready var minute : SpinBox = $CenterContainer/VBoxContainer/HBoxContainer/Minute
@onready var second : SpinBox = $CenterContainer/VBoxContainer/HBoxContainer/Second

var main_window
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('page loaded')
	button.pressed.connect(On_Button_Pressed)
	
	



func On_Button_Pressed():
	Global.focus_minutes = int(minute.value)
	Global.focus_seconds = int(second.value)
	change_page.emit(1)
