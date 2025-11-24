extends AnimatedSprite2D

#桌面宠物就是一个状态机，不同的操作进入不同的状态即可。
#pet是父节点，也是整个桌面宠物的根节点
var pet
#子节点不仅需要接收来自父节点的信号，它自身也要通过信号通知父节点状态发生变化
signal action(_State : Global.State)

var anim_list
var idle_anims = []

@onready var audio : AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#首先初始化父节点
	pet = get_parent()
	
	#将此节点的方法与信号总线上的信号进行连接。
	EventBus.sig_state_change.connect(Play_Anim)
	
	anim_list = sprite_frames.get_animation_names()
	print(anim_list)
	for item in anim_list:
		if 'Idle' in item:
			idle_anims.append(item)


#依据状态，进入对应的动画播放列表
func Play_Anim(_next_state):
	match _next_state:
		Global.State.Idle:
			play(idle_anims[randi() % idle_anims.size()])
		Global.State.Run_Left:
			play("Run_Left")
		Global.State.Run_Right:
			play("Run_Right")
		Global.State.Drag:
			play("Drag")
		Global.State.Sleep:
			play("Sleep")
		Global.State.Notice:
			play("Notice")
			audio.play()
		Global.State.Pat:
			play('Pat')
			
	pass
	
	

#动画播放完毕后尝试进入Idle状态
func _on_animation_finished() -> void:
	EventBus.sig_request_state_change.emit(Global.State.Idle)
