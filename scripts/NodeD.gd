extends Node2D


func _ready():
	var found := [await get_signals(self, [], true), ""]
	for i in found[0]:
		found[1] += str(i) + "\n"
		for j in found[0][i]:
			found[1] += str(j) + "\n"
		found[1] += "\n"
	OS.alert(found[1], "Connections to: Test._ready and lambdas")


func get_signals(node:Node = self, requested_method:Array[Callable] = [], show_lambdas := false)  -> Dictionary:
	if not has_node("Window"):
		var window := Window.new()
		window.size = get_viewport_rect().size * 0.75
		window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		var text := TextEdit.new()
		text.size = window.size
		window.add_child(text, true)
		add_child(window, true)
		window.connect("close_requested", func ():
			text.clear()
			window.set_block_signals(true)
			await get_signals()
			window.set_block_signals(false))
		window.connect("size_changed", func (): text.size = window.size)
	
	var found := {node: []}
	var indent := ""
	for i in range(str(node.get_path()).split("/").size() * 3 - 8): indent += "\t"
	$Window/TextEdit.text += "\n\n" + indent + node.name + "\n" + indent + str(node.get_path()) + "\n"
	for SIGNAL in node.get_signal_list():
		for CONNECTION in node.get_signal_connection_list(SIGNAL["name"]):
				await get_tree().create_timer(0.01).timeout
				if requested_method.is_empty() and not show_lambdas:
					$Window/TextEdit.text +=  "\t\t\t" + indent + str(CONNECTION["signal"]) + "\t\t\t\t\t\t" + str(CONNECTION["callable"]) + "\n"
					found[node].append(CONNECTION)
					continue
				if CONNECTION["callable"] in requested_method or (show_lambdas and "<anonymous lambda>(lambda)" == str(CONNECTION["callable"])):
					$Window/TextEdit.text += "\t\t\t" + indent + str(CONNECTION["signal"]) + "\t\t\t\t\t\t" + str(CONNECTION["callable"]) + "\t\t\t\tREQUESTED CONNECTION\n"
					found[node].append(CONNECTION)
	if found[node].is_empty(): found.erase(node)
	for i in node.get_children():
		found.merge(await get_signals(i, requested_method, show_lambdas))
	return found












