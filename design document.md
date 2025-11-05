# 桌面宠物设计文档

## 技术路线
- **透明小窗口**：顶层无边框 + 背景透明，始终最上。
- **渲染核心**：AnimatedSprite2D 循环播放 Idle 动画。

## 状态机（仅列当前）
- **Idle**：默认循环动画，无交互时持续。

## 交互
| 按键 | 行为 |
|---|---|
| 左键按住 | 进入 Drag 状态，跟随鼠标移动 |
| 左键释放 | 回到 Idle |
| 右键点击 | 弹出小菜单（选项待填） |

## 后续预留
- 更多状态、动画、菜单项直接追加，无需改架构。

# 项目设置

为了实现透明小窗口，我们需要对项目进行如下的配置


1. 项目设置  
   `Project → Project Settings → Display → Window`  
   - `size` 设为宠物画布大小（如 128×128）  
   - `per_pixel_transparency` → `allowed = true`  
   - `transparent` → `true`  

2. 场景根节点  
   类型：`Window`（Godot 4）或 `PopupPanel`（Godot 3）  
   属性：  
   - `transparent_bg = true`  
   - `borderless = true`  
   - `always_on_top = true`  
   - `mouse_passthrough = false`（需接收鼠标事件）  

3. 视口背景  
   脚本 `_ready()` 内：  
   `get_tree().get_root().set_transparent_background(true)`  

4. 运行验证  
   启动后除宠物像素外，其余区域完全透明，可点击桌面图标。  


# 组件交互方案

## 技术选型
- **HTTP**（TCP/127.0.0.1:23333）  
  优点：通用、任何语言都能 POST；缺点：localhost 仍走协议栈，1-2 ms 级延迟  
- **升级路线**：UNIX Domain Socket / NamedPipe → 零拷贝、&lt; 1 ms、免端口

---

## Godot 端（HTTP 客户端）

### 1. 单例 `PipeClient.gd`
```gdscript
extends Node
@onready var http := HTTPClient.new()
const HOST := "127.0.0.1"
const PORT := 23333

func _ready() -&gt; void:
	if http.connect_to_host(HOST, PORT) != OK:
		push_error("外部管道未启动")

func send(cmd: String, data: Dictionary = {}) -&gt; void:
	if http.get_status() != HTTPClient.STATUS_CONNECTED: return
	var body := JSON.stringify({"cmd":cmd} . merge(data))
	http.request(HTTPClient.METHOD_POST, "/",
				["Content-Type: application/json"], body.utf8())

## WebSocket方案（目前确定的方案）
WebSocket是一种全双工、低延迟、长连接的网络通信协议，运行在TCP之上。它允许客户端与服务器在一条持久连接上随时弧线推送数据，无需想Http那样一问一答。HTTP的服务器如果想主动给浏览器推送消息，只能用轮询，长轮询，SSE等方式。

Websocket的客户端先走HTTP发一个Upgrade请求，然后服务器回101 switching protocols。此后不再走HTTP，双方用自定义帧格式互相发消息，连接保持到任意一方关闭。

   
   
