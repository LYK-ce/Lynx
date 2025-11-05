extends Node

enum State{
	Idle,
	Run,
	Drag,
	Sleep
}

var focus_minutes : int = 0
var focus_seconds : int = 0
var left_time : int = 0
