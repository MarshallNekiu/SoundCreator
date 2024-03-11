extends Control

signal connect(node: String)
signal focused()
signal start()

@onready var connections := {$Box/ScrollBox/VBox/HBox/Time.text: [get_parent().get_node($Box/ScrollBox/VBox/HBox/Connection.text)] }
@onready var default_h_box := $Box/ScrollBox/VBox/HBox.duplicate()


func _ready():
	$Box/Name.text = name
	$Box/ScrollBox/VBox/HBox/Connection.text = name
	create()


func set_values(vals: Vector4, mix_rate: float):
	$Generator.time_start = str("%.2f" % vals.x).to_float()
	$Generator.time_end = str("%.2f" % vals.y).to_float()
	$Generator/Track.max_value = str("%.2f" % vals.y).to_float()
	$Generator.hz = str("%.4f" % vals.z).to_float()
	$Generator.volume_db = str("%.2f" % vals.w).to_float()
	if mix_rate: $Generator.stream.mix_rate = mix_rate
	
	$Box/Values.text = str(vals)


func focus():
	emit_signal("focused")


func create():
	connections.clear()
	
	for i in $Timer.get_children():
		i.queue_free()
	
	for hbox in $Box/ScrollBox/VBox.get_children().filter(func (x): return x.is_in_group("HBox")):
		connections.merge({hbox.get_node("Time").text: []} )
		
		for connection in hbox.get_children().filter(func (x): return x.is_in_group("Connection")):
			if connection.modulate == Color.DIM_GRAY or connections[hbox.get_node("Time").text].has(get_parent().get_node(connection.text)): continue
			connections[hbox.get_node("Time").text].append(get_parent().get_node(connection.text))
	
	for i in connections:
		var time := Timer.new()
		time.name = "Timer - " + i
		time.wait_time = i.to_float()
		time.one_shot = true
		start.connect(time.start)
		
		for j in connections[i]:
			time.connect("timeout", j.play)
		
		$Timer.add_child(time, true)


func play():
	$Generator.call("create_track")
	emit_signal("start")


func _on_connected_toggled(toggled_on):
	if toggled_on:
		create()
		$Connected.modulate = Color.GREEN
	else:
		for i in $Timer.get_children(): i.queue_free()
		$Connected.modulate = Color.RED


func add_connection(node: String, HBox: HBoxContainer):
	var connection:Button = $Box/ScrollBox/VBox/HBox/Connection.duplicate()
	connection.modulate = Color.WHITE
	connection.text = node
	HBox.add_child(connection, true)
	HBox.move_child(connection, -2)


func _on_h_box_child_entered_tree(node: Control):
	if node.name == "Time": node.connect("text_submitted", func(new_text: String): create())
	
	if node.name == "Control": node.get_node("Add").connect("pressed", func(): create())
	
	if node.is_in_group("Connection"):
		node.connect("pressed", func ():
			node.modulate = Color.WHITE if node.modulate == Color.DIM_GRAY else Color.DIM_GRAY
			create())
		
		node.connect("button_down", func(): get_tree().create_timer(0.3).connect("timeout", func(): if node.button_pressed and not node == $Box/ScrollBox/VBox/HBox/Connection: node.queue_free()) )
		
		if connections.has(node.get_parent().get_node("Time").text):
			node.connect("tree_exiting", func (): connections[node.get_parent().get_node("Time").text].erase(get_parent().get_node(node.text)) )


func _on_move_button_down():
	await get_tree().create_timer(0.3).timeout
	
	while $Box/Name.button_pressed or $Box/Values.button_pressed:
		var gm = get_global_mouse_position()
		global_position = Vector2((32 - int(gm.x) % 32) + int(gm.x) - 256,  (32 - int(gm.y) % 32) + int(gm.y))
		await get_tree().create_timer(0.01).timeout







