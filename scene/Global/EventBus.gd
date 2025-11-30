'''
全局信号事件总线
通过单例的方式，让所有组件的信号都与此单例的信号相连，触发也通过此信号触发即可。
'''
extends Node

#按理说不应该设置这么多信号的，不过目前只是实现，还不考虑整体的优化
#状态转换时触发的信号
signal sig_state_change(_next_state : Global.State)
#请求状态机发生状态转移时触发的信号
signal sig_request_state_change(_next_state : Global.State)
#命令信号，可能需要根据弹出菜单的选择发送不同的信号
signal sig_order(order)
#心情值变更信号，根据是否完成待办，进行心情值的变更
signal sig_mood_change(_value)
#coin值变更信号，完成待办就增加coin值
signal sig_coin_change(_value)
#打开商店的信号
signal sig_open_store()

#本地信息更新信号
signal sig_update_status()
