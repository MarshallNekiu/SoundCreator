extends Control

@onready var sub:Control = $SubBlocks/Default


func _on_sub_blocks_child_entered_tree(node: Control):
	for i in ["Box/Name", "Box/Values"]:
		node.get_node(i).connect("pressed", func ():
			if not is_instance_valid(sub): return
			sub.modulate = Color.GRAY
			sub = node
			refresh_values(sub.get_node("Box/Values").text)
			sub.modulate = Color.WHITE
			)
	
	node.get_node("Box/Values").emit_signal("pressed")
	
	node.get_node("Box/ScrollBox/VBox/HBox/Control/Add").connect("pressed", func(): node.call("add_connection", $UI/Connection.text))


func refresh_values(values: String):
	var vals := Vector4(values.get_slice(",", 0).erase(0, 1).to_float(), values.get_slice(",", 1).to_float(), values.get_slice(",", 2).to_float(), values.get_slice(",", 3).get_slice(")", 0).to_float())
	$UI.call("_on_end_text_submitted", str(vals.y))
	$UI.call("_on_track_value_changed", vals.x)
	$UI.call("_on_volume_value_changed", vals.w)


func _on_new_pressed():
	var new = preload("res://scenes/sub.tscn").instantiate()
	new.position += Vector2(512, 512)
	$SubBlocks.add_child(new, true)


func _on_remove_pressed():
	if sub == $SubBlocks/Default: return
	var x = sub
	sub = $SubBlocks/Default
	refresh_values(sub.get_node("Box/Values").text)
	x.queue_free()














