extends CanvasLayer


func _on_track_value_changed(value: float):
	$Track.set_value_no_signal(("%.2f" % value).to_float())
	$Track/Start.text = "%.2f" % value
	var x = owner.sub.get_node("Box/Values").text.split(",")
	x[0] = str(value)
	owner.sub.get_node("Box/Values").text = str(Vector4(x[0].to_float(), x[1].to_float(), x[2].to_float(), x[3].to_float()))


func _on_end_text_submitted(new_text: String):
	if not new_text.is_valid_float(): return
	new_text = "%.3f" % new_text.to_float()
	$Track.max_value = new_text.to_float()
	var x = owner.sub.get_node("Box/Values").text.split(",")
	x[1] = new_text
	owner.sub.get_node("Box/Values").text = str(Vector4(x[0].to_float(), x[1].to_float(), x[2].to_float(), x[3].to_float()))


func _on_volume_value_changed(value: float):
	var x = owner.sub.get_node("Box/Values").text.split(",")
	x[3] = str(value)
	owner.sub.get_node("Box/Values").text = str(Vector4(x[0].to_float(), x[1].to_float(), x[2].to_float(), x[3].to_float()))
	$Volume/Text.text = str(value)








