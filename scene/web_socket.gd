extends Node
class_name WebSocket          # 类名不变，外部无感

@export var URL := "ws://127.0.0.1:8787/ws"  # 对方服务器地址
#@export var URL := "ws://10.100.73.11:8787/ws" 
#@export var URL := "ws://127.0.0.1:8787"
@export var AUTO_RECONNECT := true

var _peer: WebSocketPeer
var _has_peer: bool = false
var pet


func _ready() -> void:
	pet = get_parent()
	if pet is Pet:
		EventBus.sig_order.connect(_send_text)
	else:
		push_warning("未挂在 Pet 节点下")

	_connect()          # 主动去连
	set_process(true)   # 每帧 poll

func _process(_delta: float) -> void:
	if _peer:
		_peer.poll()
		var state = _peer.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			_recv_packets()
		elif state == WebSocketPeer.STATE_CLOSED:
			print('state closed')
			_on_close()

# ---------- 客户端连接 ----------
func _connect() -> void:
	_peer = WebSocketPeer.new()
	var err = _peer.connect_to_url(URL)  # ← 关键：客户端模式
	if err != OK:
		push_error("连接失败：", err)
		if AUTO_RECONNECT:
			await get_tree().create_timer(5.0).timeout
			_connect()
		return
	print('err is:',err)
	_has_peer = true
	print("正在连接：", URL)
	#过1秒之后在发送订阅消息。
	await get_tree().create_timer(1.0).timeout
	var register_todo = {
		  "type": "listen",
		  "body": {
			"channel": "todo.due"
		  }
		}
	var json_string = JSON.stringify(register_todo)
	_send_text(json_string)
	
	var register_clock = {
		  "type": "listen",
		  "body": {
			"channel": "pomodoro.events"
		  }
		}
	json_string = JSON.stringify(register_clock)
	_send_text(json_string)

func _on_close() -> void:
	print("连接已关闭")
	_peer = null
	_has_peer = false
	if AUTO_RECONNECT:
		await get_tree().create_timer(2.0).timeout
		_connect()

# ---------- 收发 ----------
func _send_text(text: String) -> void:
	print('try to send packet')
	if _has_peer and _peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_peer.send_text(text)
	else:
		push_warning("无连接，丢弃消息：", text)

func _recv_packets() -> void:
	while _peer.get_available_packet_count():
		var pkt = _peer.get_packet()
		if _peer.was_string_packet():
			var txt = pkt.get_string_from_utf8()
			
			
			var data = JSON.parse_string(txt)   # Godot 4.x 写法
			print("收到：", data)
			if data == null:
				push_error("非法 JSON，已丢弃")
			print(data)
			if data['body']['channel'] == 'pomodoro.events':
				if data['body']['data']['type'] == 'start':
					EventBus.sig_request_state_change.emit(Global.State.Sleep)
				else:
					EventBus.sig_request_state_change.emit(Global.State.Notice)
			if data['body']['channel'] == 'todo.due':
				pet.last_state = Global.State.Sleep
				EventBus.sig_request_state_change.emit(Global.State.Notice)
				
			# 原逻辑
			

# ---------- 工具 ----------
func _parse_and_emit(json_txt: String) -> void:
	var j = JSON.new()
	if j.parse(json_txt) != OK:
		push_warning("JSON 解析失败")
		return
	# todo 具体业务
