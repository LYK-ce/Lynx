extends Node

enum State{
	Idle,
	Run_Left,
	Run_Right,
	Drag,
	Sleep,
	Notice,
	Pat,
	Dead,		#死亡状态，当心情值归零时进入这个状态
	Undefined
}

var focus_minutes : int = 0
var focus_seconds : int = 0
var left_time : int = 0
