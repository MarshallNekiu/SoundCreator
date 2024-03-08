extends AudioStreamPlayer2D


var vol := 1.0
var frame:int = 0
var executer := Expression.new()
var track: Array[Vector2]
var hz := 440.0
var phase:float = 0
var increment:float = 0
var time_start:float = 0
var time_end := 1.0
var time:float = 0


func _init():
	executer.parse("sin(phase * TAU) * exp(-time)")
	await ready
	await get_tree().create_timer(2).timeout
	create_track()


func _process(_delta):
	fill_buffer()


func fill_buffer():
	frame += 1
	time = time_end - $Time.time_left
	
	for i in get_stream_playback().get_frames_available():
		var equation = executer.execute([], self) * vol
		
		get_stream_playback().push_frame(Vector2.ONE * equation)
		track.append(Vector2.ONE * equation)
		
		phase = fmod(phase + increment, 1.0)


func create_track():
	$Time.stop()
	
	track.clear()
	phase = 0
	frame = 0
	increment = hz / stream.mix_rate
	
	$Time.start(time_end - time_start)
	while vol < 1:
		vol += 0.1
	vol = 1


func _on_timer_timeout():
	while vol > 0:
		vol -= 0.1
	vol = 0









