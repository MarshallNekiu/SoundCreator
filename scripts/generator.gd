extends AudioStreamPlayer2D


var vol := false
var frame := 0
var executer := Expression.new()
var hz := 440.0
var phase:float = 0
var increment:float = 0
var time_start:float = 0
var time_end := 1.0
var time:float = 0


func _init():
	AudioServer.add_bus(-1)
	bus = AudioServer.get_bus_name(-1)
	executer.parse("sin(phase * TAU) * exp(-time)")


func _process(_delta):
	if vol: fill_buffer()


func fill_buffer():
	frame += 1
	time = time_end - $Time.time_left
	
	for i in range(get_stream_playback().get_frames_available()):
		
		var equation = executer.execute([], self)
		
		get_stream_playback().push_frame(Vector2.ONE * equation)
		
		phase = fmod(phase + increment, 1.0)
	
	$Track.value = time


func create_track():
	increment = hz / (stream.mix_rate)
	frame = -1
	$Time.start(time_end - time_start)
	process_mode = Node.PROCESS_MODE_INHERIT
	vol = true


func _on_timer_timeout():
	process_mode = Node.PROCESS_MODE_DISABLED
	vol = false








