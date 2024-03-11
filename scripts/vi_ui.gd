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



func _on_frequency_value_changed(value):
	$Frequency/Text.text = str(frequency[value])
	_on_frequency_text_submitted(str(frequency[value]))
	$Frequency.set_value_no_signal(value)
	$Frequency/Tone.selected = value


func _on_frequency_text_submitted(new_text):
	if not new_text.is_valid_float() or not is_instance_valid(owner.sub): return
	new_text = "%.3f" % new_text.to_float()
	var x = owner.sub.get_node("Box/Values").text.split(",")
	x[2] = new_text
	owner.sub.get_node("Box/Values").text = str(Vector4(x[0].to_float(), x[1].to_float(), x[2].to_float(), x[3].to_float()))
	owner.sub.get_node("Generator").hz = new_text.to_float()


func _on_mix_rate_value_changed(value):
	$MixRate/Text.text = str(value)
	owner.sub.get_node("Generator").stream.mix_rate = value









