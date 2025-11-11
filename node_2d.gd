extends Node2D


func _ready():
	if OS.get_name() == "Windows":
		# 延迟调用，确保窗口完全创建
		
		#call_deferred("_hide_lynx_taskbar")
		call_deferred("hide_taskbar")

func hide_taskbar():
	var taskbartool := TaskBarTool.new()
	taskbartool.hide_taskbar_icon_by_title('Lynx')

func _hide_lynx_taskbar():
	var python_script =  "hide.py"
	
	# 检查脚本是否存在
	if not FileAccess.file_exists(python_script):
		push_error("❌ 未找到 Python 脚本: " + python_script)
		return
	
	# 异步执行（非阻塞）
	var pid = OS.create_process("python", [python_script])
	
	if pid > 0:
		print("✅ 正在执行 Python 脚本隐藏 Lynx 任务栏图标")
	else:
		push_error("❌ Python 执行失败，请检查是否安装")
