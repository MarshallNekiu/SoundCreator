extends Control

@onready var sub:Control = $SubBlocks/Default
var time = 0
var times: Array[float]
var connections: Dictionary


func _on_connect(node_connections: Dictionary):
	for i in node_connections:
		if not connections.has(i):
			connections.merge({i: node_connections[i]})
		else:
			for j in node_connections[i]:
				if not connections[i].has(j):
					connections[i].append(j)
	OS.alert(str(connections), "Connect")


func _on_disconnect(node_connections:Dictionary):
	for i in node_connections:
		if connections.has(i):
			for j in node_connections[i]:
				if connections[i].has(j):
					connections[i].erase(j)
	OS.alert(str(connections), "Disconnect")


func _on_debug(data):
	if not has_node("Window"):
		var window := Window.new()
		window.size = get_viewport_rect().size * 0.5
		window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		add_child(window, true)
		window.connect("close_requested", func (): window.queue_free())
		var text := TextEdit.new()
		text.size = window.size
		window.add_child(text, true)
	
	await get_tree().create_timer(0.1).timeout
	
	$Window/TextEdit.text += str(data) + "\n\n"


func _ready():
	$SubBlocks/Default/Box/ScrollBox/VBox/HBox/Connection.emit_signal("pressed")
	$SubBlocks/Default/Box/ScrollBox/VBox/HBox/AddConnection.text = "Default2"
	$SubBlocks/Default/Box/ScrollBox/VBox/HBox/AddConnection.emit_signal("text_submitted", "Default2")
	
	$SubBlocks/Default2/Box/ScrollBox/VBox/HBox/Time.text = "2.0"
	$SubBlocks/Default2/Box/ScrollBox/VBox/HBox/Time.emit_signal("text_sumbmitted", "2.0")
	$SubBlocks/Default2/Box/ScrollBox/VBox/HBox/Connection.emit_signal("pressed")
	$SubBlocks/Default2/Box/ScrollBox/VBox/HBox/AddConnection.text = "Default"
	$SubBlocks/Default2/Box/ScrollBox/VBox/HBox/AddConnection.emit_signal("text_submitted", "Default")


func _on_focus(node: Control):
	if not is_instance_valid(sub): return
	sub.modulate = Color.DIM_GRAY
	sub = node
	sub.modulate = Color.WHITE


func _on_sub_blocks_child_entered_tree(node: Control):
	node.connect("connect", _on_connect)
	node.connect("disconnect", _on_disconnect)
	node.connect("debug", _on_debug)
	node.connect("focused", _on_focus)
	node.emit_signal("focused", node)


func refresh_values(vals: Vector4):
	$UI/Track.max_value = vals.y
	$UI/Track/Start.text = str(vals.x)
	$UI/Track.set_value_no_signal(vals.x)
	$UI/Track/End.text = str(vals.y)
	$UI/Frequency/Text.text = str(vals.z)
	$UI/Volume.set_value_no_signal(vals.w)
	$UI/Volume/Text.text = str(vals.w)


func _on_new_pressed():
	var new_sub = preload("res://scenes/sub.tscn").instantiate()
	new_sub.position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	$SubBlocks.add_child(new_sub, true)


func _on_remove_pressed():
	if sub == $SubBlocks/Default: return
	var x = sub
	sub = $SubBlocks/Default
	sub.emit_signal("focused")
	x.queue_free()












