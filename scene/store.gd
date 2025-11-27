'''
商店系统，其实就是一个数值表示金币，再加上一个空的页面就足够了
现在就只管增加金币吧
'''
extends Node

@export var coin_value : int = 0

@onready var window = $Window

func _ready() -> void:
	#window.hide()



#尝试更改coin value，如果修改成负值就会返回false表示失败。不过说起来现在也用不到coin，所以不会出现减少的情况。
func Change_Coin_Value(_value)-> bool:
	var new_coin_value = coin_value + _value
	if new_coin_value < 0:
		return false
	else:
		coin_value = new_coin_value
		return true
