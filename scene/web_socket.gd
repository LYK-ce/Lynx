'''
WebSocket节点，通过这个节点与外部的进程进行通信。
这个节点完全通过信号的方式与桌面宠物的主要组件相连，这样即便不存在这个组件，桌面宠物也意识不到。
'''
extends Node
class_name WebSocket

@export var PORT = 9080
var tcp_server = TCPServer.new()
var peer :WebSocketPeer = null
var has_peer:bool = false
var pet

signal action(_next_state)

#启动服务器，游戏启动时监听9080
func _ready():
	#首先与宠物建立连接
	pet = get_parent()
	if pet is not Pet:
		print('not on a pet node')
	else:
		pet.command.connect(Send)
		action.connect(pet.Take_Action)
	#监听端口，尝试建立连接
	var err = tcp_server.listen(PORT)
	if err == OK:
		print("Server started.")
	else:
		push_error("Unable to start server.")
		set_process(false)

func Send(_text):
	if peer != null:
		peer.send_text(_text)
	else:
		print('there is no connection!')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	while tcp_server.is_connection_available():
		var raw_tcp = tcp_server.take_connection()  # 一定要先接住
		if has_peer:
			raw_tcp.disconnect_from_host()          # ① 礼貌断开
			raw_tcp = null                          # ② 释放引用
			print("已有一条连接，拒绝新客户端")
		else:
			peer = WebSocketPeer.new()
			peer.accept_stream(raw_tcp)             # 把连接升级成 WebSocket
			has_peer = true
			print("唯一客户端已接入")
		
	
	if peer == null:
		return
	
	peer.poll()
	
	var peer_state = peer.get_ready_state()
	if peer_state == WebSocketPeer.STATE_OPEN:
		while peer.get_available_packet_count():
			var packet = peer.get_packet()
			if peer.was_string_packet():
				var packet_text = packet.get_string_from_utf8()
				print('receive text',packet_text)
				#todo
				#根据输入命令，进行相应的操作
				action.emit(Global_Parameters.State.Sleep)
				# Echo the packet back.
				#peer.send_text(packet_text)
			else:
				print('unknown information')
				
	elif peer_state == WebSocketPeer.STATE_CLOSED:
		var code = peer.get_close_code()
		var reason = peer.get_close_reason()
		print("Peer closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		peer = null
		
