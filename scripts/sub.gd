extends Control

signal connect(connection: Dictionary)
signal disconnect(connection: Dictionary)
signal focused(SELF: Control)
signal start(SELF: Control)
signal debug(data)

@onready var connections:Dictionary = {$Box/ScrollBox/VBox/HBox/Time.text.to_float(): [get_parent().get_node($Box/ScrollBox/VBox/HBox/Connection.text)] as Array[Control]}
@onready var default_h_box := $Box/ScrollBox/VBox/HBox.duplicate()

var values := {"time_start": 0 as float, "time_end": 1.0, "hz": 440.0, "volume": 0 as float, "mix_rate": Global.mix_rate[2] as int}
var code := "sin(phase * TAU) * exp(-time)"


func _ready():
	$Box/Name.text = name
	$Box/ScrollBox/VBox/HBox/Connection.text = name
	create()


func set_values(vals := {"time_start": 0 as float, "time_end": 1.0, "hz": 440.0, "volume": 0 as int, "mix_rate": Global.mix_rate[2] as int}):
	for i in vals:
		match i:
			"time_start":
				values[i] = clamp(vals[i], 0, 599.99)
			"time_end":
				values[i] = clamp(vals[i], 0.01, 600.0)
			"hz":
				values[i] = clamp(vals[i], 1.0, 1000.0)
			"volume":
				values[i]= clamp(vals[i], 0, 24)
			"mix_rate":
				values[i] = clamp(vals[i], 5, 48000)
	
	$Box/Values.text = str(Vector4(values["time_start"], values["time_end"], values["hz"], values["volume"]))


func create():
	emit_signal("disconnect", connections)
	connections.clear()
	
	for hbox in $Box/ScrollBox/VBox.get_children().filter(func (x): return x.is_in_group("HBox")) as Array[HBoxContainer]:
		connections.merge( {hbox.get_node("Time").text.to_float(): []} )
		
		for connection in hbox.get_children().filter(func (x): return x.is_in_group("Connection")) as Array[Button]:
			if connection.modulate == Color.DIM_GRAY or connections[hbox.get_node("Time").text.to_float()].has(get_parent().get_node(connection.text)): continue
			connections[hbox.get_node("Time").text.to_float()].append(get_parent().get_node(connection.text))
	
	emit_signal("connect", connections)
	
	await get_tree().create_timer(0.1).timeout
	emit_signal("debug", {self: connections})


func _on_connected_toggled(toggled_on):
	if toggled_on:
		create()
		$Connected.modulate = Color.GREEN
	else:
		emit_signal("disconnect", connections)
		$Connected.modulate = Color.RED


func _on_add_time_text_submitted(new_text: String):
	$Box/ScrollBox/VBox.add_child(default_h_box.duplicate(), true)
	$Box/ScrollBox/VBox.get_child(-1).get_node("Time").text = new_text
	$Box/ScrollBox/VBox.get_child(-1).get_node("Connection").queue_free()
	$Box/ScrollBox/VBox.move_child($Box/ScrollBox/VBox.get_child(-1), -2)


func _on_add_connection_text_submitted(text: LineEdit):
	if not get_parent().has_node(text.text as String):
		OS.alert(text.text + " Not Found")
		return
	elif text.text in text.get_parent().get_children().filter(func (x: Control): return x.is_in_group("Connection")).map(func (x: Button): return x.text):
		OS.alert("Not Duplicate")
		return
	var connection:Button = $Box/ScrollBox/VBox/HBox/Connection.duplicate()
	connection.modulate = Color.WHITE
	connection.text = text.text
	text.get_parent().add_child(connection, true)
	text.get_parent().move_child(connection, -2)
	
	create()


func toggle_connection(connection: Button):
	connection.modulate = Color.WHITE if connection.modulate == Color.DIM_GRAY else Color.DIM_GRAY
	create()


func remove_connection(connection: Button):
	await get_tree().create_timer(0.3).timeout
	if connection.button_pressed and not connection == $Box/ScrollBox/VBox/HBox/Connection:
		connection.queue_free()
		create()


func _on_h_box_child_entered_tree(node: Control):
	if node.is_in_group("Connection"):
		node.connect("pressed", func (): toggle_connection(node))
		node.connect("button_down", func(): remove_connection(node))
	
	if "Add" in node.name: node.connect("text_submitted", func(new_text): _on_add_connection_text_submitted(node))


func _on_move_button_down(button: NodePath):
	await get_tree().create_timer(0.3).timeout
	while get_node(button).button_pressed:
		position = Global.pos_to_grid(get_global_mouse_position())
		await get_tree().create_timer(0.01).timeout


func _on_focus():
	emit_signal("focused", self)






