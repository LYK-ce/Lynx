'''
心情值系统
完成待办心情值上升，如果待办失败就心情值下降。目前就设计存在这么一个数值好了

实际上直接将这一部分整合到Pet节点中是最好的，不过这里还是将其分开吧。
还是通过信号总线的方式与其他组件进行交互
'''
extends Node
@export var mood_value : int = 100
@export var mood_value_max : int = 100
@export var mood_value_min : int = 0

@onready var progress_bar = $ProgressBar

func _ready() -> void:
	progress_bar.max_value = mood_value_max
	progress_bar.min_value = mood_value_min
	
	#显然心情值是需要被保存下来的，在每次启动时将这个值读取出来
	#不一定放在这里做,为了进行测试，我们首先在这里手动设置数值
	Set_Mood_Value(50)
	
	#和信号关联起来
	EventBus.sig_mood_change.connect(Change_Mood_value)

func Update_Mood_Value():
	#当信号数值归零时就发出宠物死亡信号，确保mood value在范围内，最后更新progress bar
	if mood_value <= 0 :
		EventBus.sig_request_state_change.emit(Global.State.Dead)
	#其余情况下，确保mood value在正确的范围内
	mood_value = clamp(mood_value, mood_value_min, mood_value_max)
	progress_bar.value = mood_value
	
#直接设置心情值
func Set_Mood_Value(_value):
	mood_value = _value
	Update_Mood_Value()
	
#修改心情值，增加就是正值，减少就是负值
#这个函数还将通过信号总线的方式与其他组件连接起来。
func Change_Mood_value(_value):
	mood_value += _value
	Update_Mood_Value()
