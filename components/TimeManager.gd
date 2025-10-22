extends Node2D

@onready var minute_timer := $MinuteTimer

@export var minutes_per_tick := 30       # how many in-game minutes added per timer tick
@export var seconds_per_tick := .2     # real seconds between ticks (tunes game speed)
@export var start_hour := 8             # 1..12
@export var start_is_am := true        # false = PM
@export var end_hour := 4

var current_day = 1                 # day ends at 4 AM

var hours : int
var minutes : int
var is_am : bool

signal time_changed(hours:int, minutes:int, is_am:bool)
signal day_over()

func _ready() -> void:
	minute_timer.timeout.connect(_on_tick)
	call_deferred("start_day")

func start_day():
	current_day = DataManager.get_game_day()
	hours = DataManager.get_game_hours()
	minutes = DataManager.get_game_minutes()
	is_am = DataManager.get_game_is_am()
	
	minute_timer.wait_time = seconds_per_tick
	minute_timer.one_shot = false
	minute_timer.start()
	emit_signal("time_changed",hours,minutes,is_am)

func _on_tick():
	_add_minutes(minutes_per_tick)
	emit_signal("time_changed", hours, minutes, is_am)
	
	DataManager.set_time(current_day, hours, minutes, is_am)
	# End at 4:00 AM	
	if hours == end_hour and is_am and minutes == 0:
		minute_timer.stop()
		
		current_day += 1
		hours = start_hour
		minutes = 0
		is_am = start_is_am
		DataManager.set_time(current_day, hours, minutes, is_am)
		DataManager.save_game()
		day_over.emit()
		minute_timer.start()

func _add_minutes(delta:int) -> void:
	minutes += delta
	# carry minutes -> hours (works for any delta)
	if minutes >= 60:
		var hours_to_add = minutes / 60
		minutes = minutes % 60
		for _i in range(hours_to_add):
			hours += 1
			if hours == 12: # Just rolled over from 11:xx
				is_am = !is_am
			elif hours == 13: # Just rolled over from 12:xx
				hours = 1
	
