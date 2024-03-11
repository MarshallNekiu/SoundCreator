extends Node2D

signal test()


var effect_list := {"Default": "sin(phase * TAU)"}
@onready var ActualEffect:HBoxContainer = $UI/Track/Sub/Scroll/VBox/Default
@onready var actual_file:HBoxContainer = $UI/Track/File/Scroll/VBox/Default
@onready var selected_file: HBoxContainer = $UI/Track/File/Scroll/VBox/Default
var frequency:Array[float] = [32.7032, 34.6479, 36.7081, 38.8909, 41.2035, 43.6536, 46.2493, 48.9995, 51.9130, 55.0, 58.2705, 61.7354]
var directory := DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))


func debug_notify(notif := ""):
	%Debug.add_child(Label. new(), true)
	%Debug.get_child(-1).text = notif
	if %Debug.get_child_count() > 10:
		%Debug.remove_child(%Debug.get_child(0))

func _init():
	for i in range(5 * 12 - 12): frequency.append(frequency[int(i) % 12] * (2 ** ( (i / 12) + 1) ) )
	
	if not directory.get_directories().has("SoundCreator"):
		directory.make_dir("./SoundCreator")
		directory.make_dir("./SoundCreator/data")
		directory.make_dir("./SoundCreator/audio")
	directory.change_dir("./SoundCreator")


func _ready():
	var tones := ["C", "Cs", "D", "Ds", "E", "F", "Fs", "G", "Gs", "A", "As", "B"]
	for i in range(frequency.size()):
		$UI/Track/Main/Configs/Frequency/Tone.add_item(tones[i % 12] + " " + str(i / 12 + 1) )
	$UI/Track/Main/Configs/Frequency/Tone.selected = frequency.size() / 2
	$UI/Track/Main/Configs/Frequency.max_value = frequency.size() - 1
	$UI/Track/Main/Configs/Frequency.value = frequency.size() / 2
	
	if not FileAccess.file_exists(directory.get_current_dir() + "/data/Default.txt"):
		debug_notify("./data empty. Creating Default...")
		var test := FileAccess.open(directory.get_current_dir() + "/data/Default.txt", FileAccess.WRITE)
		test.store_string("effect_list ?0 Default ?2 sin(phase * TAU) ?2 (0, 1, 440, 0) ?1 Sub ?2 sin(phase * TAU) * exp(-time) ?2 (0.1, 0.3, 440, 0) ?3 (0.5, 0.7, 440, 0)")
		test.close()
	
	for i in directory.get_files_at(directory.get_current_dir() + "/data"):
		if i == "Default.txt": continue
		await $UI.call("_on_file_new_pressed")
		$UI/Track/File/Scroll/VBox.get_child(-1).get_node("Name").text = i.get_slice(".", 0)
		debug_notify(i + " Loaded")
	
	load_file()
	
	var lam := "test"
	get_tree().create_timer(1).connect("timeout", func(): OS.alert("teste" + lam))


func _input(event):
	if event is InputEventScreenDrag:
		$Camera.position += event.relative * 2
	
	$UI/Track/Sub/Line2D.global_position.y = clamp(ActualEffect.global_position.y + 8, 80, 480)
	$UI/Track/File/Line2D.global_position.y = clamp(actual_file.global_position.y + 8, 80, 480)
	
	if event is InputEventKey or event is InputEventMouse:
		if DisplayServer.virtual_keyboard_get_height() > 0:
			$Camera.zoom.y = 1.0
		else:
			$Camera.zoom.y = 1.0
	
	if event is InputEventMouse:
		$Mouse.global_position = get_global_mouse_position()
		$Label.text = ActualEffect.name + "\n" + actual_file.name


func _on_mouse_area_entered(area: Area2D):
	match str(area.get_path()).get_slice("/", 5):
		"Sub":
			debug_notify("Actual Sub: " + ActualEffect.name + " -> " + area.get_parent().name)
			ActualEffect = area.get_parent()
			$UI/Track/Sub/Code.text = effect_list[ActualEffect.name]
		"File":
			debug_notify("Actual File: " + actual_file.name + " -> " + area.get_parent().name)
			actual_file = area.get_parent()


func new_file():
	var newfile := FileAccess.open(directory.get_current_dir() + "/data/" + $UI/Track/File/Scroll/VBox.get_child(-1).name + ".txt", FileAccess.WRITE)
	newfile.store_string("effect_list ?0 Default ?2 sin(phase * TAU) ?2 (0, 1, 440, 0)")
	newfile.close()
	debug_notify("File Created")


func load_file():
	var file := FileAccess.open(directory.get_current_dir() + "/data/" + actual_file.name + ".txt", FileAccess.READ)
	selected_file = actual_file
	var info := Array(file.get_as_text().split("\n"))
	for i in info:
		var data: String = info.pop_front()
		match data.get_slice(" ?0 ", 0):
			"effect_list":
				ActualEffect = $UI/Track/Sub/Scroll/VBox/Default
				effect_list.clear()
				
				for j in $UI/Track/Sub/Scroll/VBox.get_children():
					if j == $UI/Track/Sub/Scroll/VBox/Default: continue
					j.queue_free()
				
				var subs := data.get_slice(" ?0 ", 1).split(" ?1 ")
				
				for j in subs:
					if j.get_slice(" ?2 ", 0) == "Default":
						effect_list.merge({"Default": j.get_slice(" ?2 ", 1)})
						$UI/Track/Sub/Scroll/VBox/Default/Values.text = j.get_slice(" ?2 ", 2)
						continue
					
					$UI/Track/Sub/Code.text = j.get_slice(" ?2 ", 1)
					await $UI.call("_on_sub_new_pressed")
					$UI/Track/Sub/Scroll/VBox.get_child(-1).get_node("Name").text = j.get_slice(" ?2 ", 0)
					for k in j.get_slice(" ?2 ", 2).split(" ?3 "):
						await $UI.call("_on_sub_add_pressed")
						$UI/Track/Sub/Scroll/VBox.get_child(-1).get_child(-1).text = k
	debug_notify("File Loaded: " + actual_file.name)


func _on_file_remove_pressed():
	if actual_file == $UI/Track/File/Scroll/VBox/Default: return
	var to_remove := actual_file
	actual_file = $UI/Track/File/Scroll/VBox/Default
	directory.remove("./data/" + to_remove.name + ".txt")
	debug_notify("File Removed: " + to_remove.name)
	to_remove.queue_free()


func _on_test_pressed():
	for i in $Audio.get_children():
		i.queue_free()
	
	for sub in $UI/Track/Sub/Scroll/VBox.get_children():
		for Values in sub.get_children().filter(func (x): return "Values" in x.name):
			var audio: AudioStreamPlayer2D = preload("res://scenes/generator.tscn").instantiate()
			audio.name = sub.name
			var values := Vector4(Values.text.get_slice(",", 0).get_slice("(", 0).to_float(), Values.text.get_slice(",", 1).to_float(), Values.text.get_slice(",", 2).to_float(), Values.text.get_slice(",", 3).get_slice(")", 0).to_float())
			audio.executer.parse(effect_list[sub.name])
			audio.hz = values.z
			audio.time_start = 0
			audio.time_end = values.y
			audio.volume_db = values.w
			get_tree().create_timer(values.x + 1).connect("timeout", func (): $Audio.add_child(audio))


func _on_q_save_pressed():
	var data := "effect_list ?0 "
	for i in $UI/Track/Sub/Scroll/VBox.get_children():
		var sub := i.name + " ?2 "
		sub += effect_list[i.name]
		for j in i.get_children():
			if j.name == "Values":
				sub += " ?2 "
			if "Values" in j.name:
				sub += j.text
				if not j == i.get_child(-1):
					sub += " ?3 "
		if not i == $UI/Track/Sub/Scroll/VBox.get_child(-1):
			sub += " ?1 "
		data += sub
	
	var file := FileAccess.open(directory.get_current_dir() + "/data/" + selected_file.name + ".txt", FileAccess.WRITE)
	file.store_string(data)
	file.close()
	debug_notify("Data Saved at " + selected_file.name)


func _on_save_pressed():
	var x := selected_file
	selected_file = actual_file
	await _on_q_save_pressed()
	selected_file = x



















