extends AnimatedSprite2D

#桌面宠物就是一个状态机，不同的操作进入不同的状态即可。

var state = Global.State.Idle
var anim_list
var idle_anims = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_list = sprite_frames.get_animation_names()
	print(anim_list)
	for item in anim_list:
		if 'Idle' in item:
			idle_anims.append(item)
	pass # Replace with function body.

#依据状态，进入对应的动画播放列表
func Play_Anim(_next_state):
	match _next_state:
		Global.State.Idle:
			state = _next_state
			play(idle_anims[randi() % idle_anims.size()])
		Global.State.Drag:
			state = _next_state
			play("Drag")
		Global.State.Sleep:
			state = _next_state
			play("Sleep")
	pass
	
	

#动画播放完毕后触发此函数
func _on_animation_finished() -> void:
	Play_Anim(Global.State.Idle)
	pass # Replace with function body.
