'''
全局信号事件总线
通过单例的方式，让所有组件的信号都与此单例的信号相连，触发也通过此信号触发即可。
'''
extends Node

#状态转换时触发的信号
signal sig_state_change(_next_state : Global.State)
#请求状态机发生状态转移时触发的信号
signal sig_request_state_change(_next_state : Global.State)
#命令信号，可能需要根据弹出菜单的选择发送不同的信号
signal sig_order(order)
