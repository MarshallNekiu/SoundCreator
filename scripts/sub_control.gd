extends Control

@onready var sub:Control = $SubBlocks/Default


func _ready():
	await get_tree().create_timer(0.1).timeout
	
	$SubBlocks/Default/Box/ScrollBox/VBox/HBox/Connection.emit_signal("pressed")
	$SubBlocks/Default.call("add_connection", $UI/Connection.text, $SubBlocks/Default/Box/ScrollBox/VBox/HBox)
	$SubBlocks/Default.call("create")
	
	$SubBlocks/Default2/Box/ScrollBox/VBox/HBox/Connection.emit_signal("pressed")
	$SubBlocks/Default2.call("add_connection", "Default", $SubBlocks/Default2/Box/ScrollBox/VBox/HBox)
	$SubBlocks/Default2.call("create")


func _on_sub_blocks_child_entered_tree(node: Control):
	node.connect("focused", func ():
		if not is_instance_valid(sub): return
		sub.modulate = Color.GRAY
		sub = node
		sub.modulate = Color.WHITE
		refresh_values(sub.get_node("Box/Values").text)
		$UI/MixRate.set_value_no_signal(sub.get_node("Generator").stream.mix_rate)
		$UI/MixRate/Text.text = str($UI/MixRate.value)
		)
	
	node.emit_signal("focused")
	
	node.get_node("Box/ScrollBox/VBox").connect("child_entered_tree", func(hbox: Control):
		if hbox.is_in_group("HBox"):
			hbox.get_node("Control/Add").connect("pressed", func (): node.call("add_connection", $UI/Connection.text, hbox)) )


func refresh_values(values: String):
	var vals := Vector4(values.get_slice(",", 0).erase(0, 1).to_float(), values.get_slice(",", 1).to_float(), values.get_slice(",", 2).to_float(), values.get_slice(",", 3).get_slice(")", 0).to_float())
	$UI/Track.max_value = vals.y
	$UI/Track/Start.text = str(vals.x)
	$UI/Track.set_value_no_signal(vals.x)
	$UI/Track/End.text = str(vals.y)
	$UI/Frequency/Text.text = str(vals.z)
	$UI/Volume.set_value_no_signal(vals.w)
	$UI/Volume/Text.text = str(vals.w)


func _on_new_pressed():
	var new_sub = preload("res://scenes/sub.tscn").instantiate()
	new_sub.position += Vector2(512, 512)
	$SubBlocks.add_child(new_sub, true)


func _on_remove_pressed():
	if sub == $SubBlocks/Default: return
	var x = sub
	sub = $SubBlocks/Default
	sub.emit_signal("focused")
	x.queue_free()














