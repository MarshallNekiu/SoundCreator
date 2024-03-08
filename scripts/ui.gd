extends Node2D


func _on_sub_start_text_submitted(new_text: String):
	$Track/Main/SubStart.set_value_no_signal(new_text.to_float())


func _on_sub_end_text_submitted(new_text: String):
	$Track/Main/SubEnd.set_value_no_signal(new_text.to_float())


func _on_sub_start_value_changed(value: float):
	$Track/Main/SubStart/Text.text = str(value)


func _on_sub_end_value_changed(value: float):
	$Track/Main/SubEnd/Text.text = str(value)


func _on_sub_add_pressed():
	var NewSubValues: LineEdit = $Track/Sub/Scroll/VBox/Default/Values.duplicate()
	NewSubValues.text = str(Vector4($Track/Main/SubStart.value, $Track/Main/SubEnd.value, $Track/Main/Configs/Frequency/Text.text.to_float(), $Track/Main/Configs/Volume.value))
	owner.ActualEffect.add_child(NewSubValues, true)


func _on_main_start_text_submitted(new_text: String):
	$Track/Main/Main.set_value_no_signal(new_text.to_float())


func _on_main_end_text_submitted(new_text: String):
	$Track/Main/Main.max_value = new_text.to_float()
	$Track/Main/SubStart.max_value = new_text.to_float()
	$Track/Main/SubEnd.max_value = new_text.to_float()


func _on_main_value_changed(value: float):
	$Track/Main/Main/Start.text = str(value)


func _on_volume_text_submitted(new_text: String):
	$Track/Main/Configs/Volume.set_value_no_signal(new_text.to_float())


func _on_volume_value_changed(value: float):
	$Track/Main/Configs/Volume/Text.text = str(value)


func _on_tone_item_selected(index: int):
	$Track/Main/Configs/Frequency.set_value_no_signal(index)
	$Track/Main/Configs/Frequency/Text.text = str(owner.frequency[index])


func _on_frequency_value_changed(value: float):
	$Track/Main/Configs/Frequency/Tone.selected = int(value)
	$Track/Main/Configs/Frequency/Text.text = str(owner.frequency[int(value)])


func _on_sub_new_pressed():
	var NewSub := HBoxContainer.new()
	NewSub.name = "Sub"
	NewSub.add_child($Track/Sub/Scroll/VBox/Default/Area.duplicate(), true)
	NewSub.add_child($Track/Sub/Scroll/VBox/Default/Name.duplicate(), true)
	$Track/Sub/Scroll/VBox.add_child(NewSub, true)
	NewSub.get_node("Name").text = NewSub.name
	owner.effect_list.merge({NewSub.name: $Track/Sub/Code.text})
	owner.ActualEffect = NewSub


func _on_sub_toggle_pressed():
	for i in owner.ActualEffect.get_children():
		if i.name == "Area":
			continue
		var j: LineEdit = i
		if j.has_selection():
			j.editable = false if j.editable else true
			j.virtual_keyboard_enabled = j.editable
			j.deselect()


func _on_track_tab_selected(tab: int):
	match tab:
		0:
			for i in $Track/Sub/Scroll/VBox.get_children():
				i.get_node("Area/Collision").disabled = true
			for i in $Track/File/Scroll/VBox.get_children():
				i.get_node("Area/Collision").disabled = true
		1:
			for i in $Track/Sub/Scroll/VBox.get_children():
				i.get_node("Area/Collision").disabled = false
			for i in $Track/File/Scroll/VBox.get_children():
				i.get_node("Area/Collision").disabled = true
		2:
			for i in $Track/Sub/Scroll/VBox.get_children():
				i.get_node("Area/Collision").disabled = true
			for i in $Track/File/Scroll/VBox.get_children():
				i.get_node("Area/Collision").disabled = false


func _on_sub_remove_pressed():
	if owner.ActualEffect.get_node("Name").has_selection():
		var to_remove: HBoxContainer = owner.ActualEffect
		owner.ActualEffect = $Track/Sub/Scroll/VBox.get_child(0)
		to_remove.queue_free()
		owner.effect_list.erase(to_remove.name)
		OS.alert(str(owner.effect_list))
		return
	
	for i in owner.ActualEffect.get_children():
		if i.name == "Area":
			continue
		if i.has_selection():
			i.queue_free()


func _on_sub_update_pressed():
	owner.effect_list[owner.ActualEffect.name] = $Track/Sub/Code.text


func _on_file_new_pressed():
	var NewFile := $Track/File/Scroll/VBox/Default.duplicate()
	NewFile.name = "File"
	NewFile.get_node("DefaultValues").text = str(Vector4(0, 1, 440, 0))
	NewFile.get_node("ValuesCount").text = "1"
	$Track/File/Scroll/VBox.add_child(NewFile, true)
	NewFile.get_node("Name").text = NewFile.name
	
	owner.call("new_file")










