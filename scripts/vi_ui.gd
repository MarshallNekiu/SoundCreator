extends CanvasLayer

var frequency:Array[float] = [32.7032, 34.6479, 36.7081, 38.8909, 41.2035, 43.6536, 46.2493, 48.9995, 51.9130, 55.0, 58.2705, 61.7354]


func _init():
	for i in range(5 * 12 - 12): frequency.append(frequency[int(i) % 12] * (2 ** ( (i / 12) + 1) ) )


func _ready():
	var tones := ["C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B"]
	for i in range(frequency.size()):
		$Frequency/Tone.add_item(tones[i % 12] + " " + str(i / 12 + 1) )
	$Frequency/Tone.selected = frequency.size() / 2
	$Frequency.max_value = frequency.size() - 1
	$Frequency.value = frequency.size() / 2


func change_values():
	owner.sub.call("set_values", Vector4($Track/Start.text.to_float(), $Track/End.text.to_float(), $Frequency/Text.text.to_float(), $Volume.value), $MixRate.value)


func _on_track_value_changed(value: float):
	$Track/Start.text = "%.2f" % value
	change_values()


func _on_end_text_submitted(new_text: String):
	if not new_text.is_valid_float(): return
	$Track.max_value = new_text.to_float()
	change_values()


func _on_volume_value_changed(value: float):
	change_values()
	$Volume/Text.text = str(value)



func _on_frequency_value_changed(value):
	$Frequency/Text.text = str(frequency[value])
	_on_frequency_text_submitted(str(frequency[value]))
	$Frequency.set_value_no_signal(value)
	$Frequency/Tone.selected = value


func _on_frequency_text_submitted(new_text):
	if not new_text.is_valid_float() or not is_instance_valid(owner.sub): return
	change_values()


func _on_mix_rate_value_changed(value):
	$MixRate/Text.text = str(value)
	change_values()









