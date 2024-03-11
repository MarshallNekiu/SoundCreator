extends Control

signal connect(node: String)
signal start()

@onready var connections := {$Box/ScrollBox/VBox/HBox/Time.text: [get_parent().get_node($Box/ScrollBox/VBox/HBox/Connection.text)] }
@onready var default_h_box := $Box/ScrollBox/VBox/HBox.duplicate()


func _ready():
	$Box/Name.text = name
	create()


func create():
	$Connected.modulate = Color.GREEN
	
	var values := Vector4($Box/Values.text.get_slice(",", 0).get_slice("(", 0).to_float(), $Box/Values.text.get_slice(",", 1).to_float(), $Box/Values.text.get_slice(",", 2).to_float(), $Box/Values.text.get_slice(",", 3).get_slice(")", 0).to_float())
	$Generator.time_start = values.x
	$Generator.time_end = values.y
	$Box/Track.max_value = values.y
	$Generator.hz = values.z
	$Generator.volume_db = values.w
	
	connections.clear()
	
	for hbox in $Box/ScrollBox/VBox.get_children().filter(func (x): return x.is_in_group("HBox")):
		connections.merge({hbox.get_node("Time").text: []} )
		
		for connection in $Box/ScrollBox/VBox/HBox.get_children().filter(func (x): return x.is_in_group("Connection")):
			if connection.modulate == Color.GRAY: continue
			connections[hbox.get_node("Time").text].append(get_parent().get_node(connection.text))


func play():
	emit_signal("start")
	
	$Generator.create_track()


func _start():
	for i in connections:
		for j in connections[i]:
			var time := get_tree().create_timer(i.to_float())
			time.connect("timeout", connections[i][connections[i].find(j)].play)
			OS.alert(str(time.get_signal_connection_list("timeout")))
	
	while $Generator.vol:
		$Box/Track.value = $Generator.time
		await get_tree().create_timer(0.02).timeout


func _on_connected_toggled(toggled_on):
	if toggled_on:
		create()
	else:
		connections.clear()
		$Connected.modulate = Color.RED


func add_connection(node: String):
	var connection = $Box/ScrollBox/VBox/HBox/Connection.duplicate()
	connection.text = node
	$Box/ScrollBox/VBox/HBox.add_child(connection, true)
	$Box/ScrollBox/VBox/HBox.move_child(connection, -2)


func _on_h_box_child_entered_tree(node: Control):
	if "Connection" in node.name:
		node.connect("pressed", func (): node.modulate = Color.WHITE if node.modulate == Color.GRAY else Color.GRAY)
		
		node.connect("button_down", func(): get_tree().create_timer(0.3).connect("timeout", func(): if node.button_pressed and not node == $Box/ScrollBox/VBox/HBox/Connection: node.queue_free()) )
		
		if connections.has(node.get_parent().get_node("Time").text):
			node.connect("tree_exiting", func (): connections[node.get_parent().get_node("Time").text].erase(get_parent().get_node(node.text)) )
		OS.alert(str(connections))


func _on_name_button_down():
	await get_tree().create_timer(0.2).timeout
	
	while $Box/Name.button_pressed:
		var gm = get_global_mouse_position()
		global_position = Vector2((32 - int(gm.x) % 32) + int(gm.x) - 256,  (32 - int(gm.y) % 32) + int(gm.y))
		await get_tree().create_timer(0.01).timeout










