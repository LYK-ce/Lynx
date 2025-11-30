'''
商店系统，其实就是一个数值表示金币，再加上一个空的页面就足够了
现在就只管增加金币吧
'''
extends Node2D

@export var coin_value : int = 0

@onready var window = $Window

@onready var particle : GPUParticles2D = $GPUParticles2D
@onready var sound : AudioStreamPlayer = $AudioStreamPlayer
@onready var coin_value_text : Label = $Window/value

func _ready() -> void:

	EventBus.sig_open_store.connect(Open_Store)
	EventBus.sig_coin_change.connect(Change_Coin_Value)
	#可能需要进行持久化，把心情值读取出来

func Set_Coin(_value):
	coin_value_text.text = str(_value)
	

#尝试更改coin value，如果修改成负值就会返回false表示失败。不过说起来现在也用不到coin，所以不会出现减少的情况。
func Change_Coin_Value(_value)-> bool:
	#如果是正值的话就播放音效，释放粒子试一试
	if _value > 0:
		particle.amount = _value
		particle.restart()
		sound.play()
	var new_coin_value = coin_value + _value
	if new_coin_value < 0:
		return false
	else:
		coin_value = new_coin_value
		return true

func Open_Store():
	print('window open')
	window.show()


func Close_Store():
	print('try to close store')
	window.hide()
