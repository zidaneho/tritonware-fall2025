extends Node2D

@onready var minute_timer := $MinuteTimer

@export var minutes_per_tick := 10        # how many in-game minutes added per timer tick
@export var seconds_per_tick := .7      # real seconds between ticks (tunes game speed)
@export var start_hour := 12              # 1..12
@export var start_is_am := false          # false = PM
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
	hours = start_hour
	minutes = 0
	is_am = start_is_am
	minute_timer.wait_time = seconds_per_tick
	minute_timer.one_shot = false
	minute_timer.start()
	_on_tick()

func _on_tick():
	_add_minutes(minutes_per_tick)
	emit_signal("time_changed", hours, minutes, is_am)
	# End at 4:00 AM
	if hours == end_hour and is_am and minutes == 0:
		minute_timer.stop()
		day_over.emit()
		current_day += 1

func _add_minutes(delta:int) -> void:
	minutes += delta
	# carry minutes -> hours (works for any delta)
	if minutes >= 60:
		hours += minutes / 60
		minutes = minutes % 60
	# wrap 12-hour format, flip AM/PM on each 12->1 roll
	while hours > 12:
		hours -= 12
		is_am = !is_am
