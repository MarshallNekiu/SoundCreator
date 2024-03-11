extends AudioStreamPlayer2D


var vol := false
var frame:int = 0
var executer := Expression.new()
var hz := 440.0
var phase:float = 0
var increment:float = 0
var time_start:float = 0
var time_end := 1.0
var time:float = 0


func _init():
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


func create_track():
	increment = hz / (stream.mix_rate * 2)
	frame = 0
	$Time.start(time_end - time_start)
	vol = true


func _on_timer_timeout():
	vol = false








