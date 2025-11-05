extends Window

@export var Page :Array[PackedScene] = []

#当前页面id
var current_page_idx = -1
var current_page = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Change_Page(0)
	pass # Replace with function body.




func Change_Page(_id):
	#首先卸载当前页面
	if current_page_idx != -1:
		current_page.queue_free()
		pass
	var new_page = Page[_id].instantiate()
	current_page = new_page
	current_page_idx = _id
	print('add before')
	self.add_child(new_page)
	new_page.change_page.connect(Change_Page)
	print('add after')
		
	


func _on_close_requested() -> void:
	self.queue_free()
