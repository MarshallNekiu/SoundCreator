class_name Global
extends Node


static var mix_rate := [8000, 11025, 22050, 32000, 44100, 48000]
static var frequency:Array[float] = [32.7032, 34.6479, 36.7081, 38.8909, 41.2035, 43.6536, 46.2493, 48.9995, 51.9130, 55.0, 58.2705, 61.7354]

static func sort_chiodren(node: Node, reverse := false):
	var list: Array[String]
	
	for i in node.get_children():
		if "_" in i.name and i.name.replace("_", ".").is_valid_float():
			list.append("%.{dec}f".format({"dec": i.name.split("_")[1].length()}) % i.name.replace("_", ".").to_float() as String)
		else:
			list.append(i.name as String)
	
	list.sort()
	if not reverse: list.reverse()
	
	for i in list:
		if "." in i:
			node.move_child(node.get_node(str(i).replace(".", "_")), 0)
		else:
			node.move_child(node.get_node(i), 0)
			


static func get_signals(node:Node, requested_method:Array[Callable] = [], show_lambdas := false)  -> Dictionary:
	var found := {node: []}
	
	for SIGNAL in node.get_signal_list():
		for CONNECTION in node.get_signal_connection_list(SIGNAL["name"]):
			if requested_method.is_empty() and not show_lambdas:
				found[node].append(CONNECTION)
				continue
			if CONNECTION["callable"] in requested_method or (show_lambdas and "<anonymous lambda>(lambda)" == str(CONNECTION["callable"])):
				found[node].append(CONNECTION)
	
	if found[node].is_empty(): found.erase(node)
	
	for i in node.get_children():
		found.merge(await get_signals(i, requested_method, show_lambdas))
	
	return found


static func pos_to_grid(pos: Vector2i, grid_step := Vector2i(32, 32)):
	return Vector2(grid_step.x - pos.x % grid_step.x + pos.x, grid_step.y - pos.y % grid_step.y + pos.y)


















