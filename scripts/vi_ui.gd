extends CanvasLayer


func _init():
	for i in range(5 * 12 - 12): Global.frequency.append(Global.frequency[int(i) % 12] * (2 ** ( (i / 12) + 1) ) )


func _ready():
	var tones := ["C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B"]
	for i in range(Global.frequency.size()):
		$Frequency/Tone.add_item(tones[i % 12] + " " + str(i / 12 + 1) )
	$Frequency/Tone.selected = Global.frequency.size() / 2
	$Frequency.max_value = Global.frequency.size() - 1
	$Frequency.value = Global.frequency.size() / 2


func change_values():
	get_parent().sub.call("set_values", {"time_start": $Track.value, "time_end": $Track.max_value, "hz": $Frequency/Text.text.to_float(), "volume": $Volume.value as int, "mix_rate": $MixRate.value})


func _on_track_value_changed(value: float):
	$Track/Start.text = "%.2f" % value
	change_values()


func _on_end_text_submitted(new_text: String):
	if not new_text.is_valid_float(): return
	$Track.max_value = str("%.2f" % new_text.to_float()) as float
	change_values()


func _on_volume_value_changed(value: float):
	change_values()
	$Volume/Text.text = str(value)



func _on_frequency_value_changed(value):
	$Frequency/Text.text = str(Global.frequency[value])
	_on_frequency_text_submitted(str(Global.frequency[value]))
	$Frequency.set_value_no_signal(value)
	$Frequency/Tone.selected = value


func _on_frequency_text_submitted(new_text):
	if not new_text.is_valid_float() or not is_instance_valid(owner.sub): return
	change_values()


func _on_mix_rate_value_changed(value):
	$MixRate/Text.text = str(value)
	change_values()









