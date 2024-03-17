extends AudioStreamPlayer2D


var waves := ["sin(phase * TAU) * exp(-time)"]
var vol := false
var frame := 0
var executer := Expression.new()
var hz := 440.0
var phase:float = 0
var increment:float = 0
var time_start:float = 0
var time_end := 1.0
var time:float = 0


func set_values(values := {"time_start": 0, "time_end": 1.0, "hz": 440.0, "volume": 0, "mix_rate": Global.mix_rate[2]}):
	time_start = values["time_start"]
	time_end = values["time_end"]
	hz = values["hz"]
	stream.mix_rate = values["mix_rate"]
	increment = hz / stream.mix_rate
	volume_db = values["volume"]


func _process(_delta):
	if vol: fill_buffer()


func fill_buffer():
	frame += 1
	time = 3.0 - $Time.time_left
	
	for i in range(get_stream_playback().get_frames_available()):
		
		var equation := 0 as float
		for j in waves:
			executer.parse(j)
			equation += executer.execute([], self)
		
		get_stream_playback().push_frame(Vector2.ONE * equation)
		
		phase = fmod(phase + increment, 1.0)
	
	$Track.value = time


func create_track():
	increment = hz / stream.mix_rate
	frame = -1
	$Time.start(3.0 - time_start)
	process_mode = Node.PROCESS_MODE_INHERIT
	vol = true


func _on_timer_timeout():
	process_mode = Node.PROCESS_MODE_DISABLED
	vol = false








