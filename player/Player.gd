extends Node2D

export(float) var speed = 5.0
export(int) var tile_size = 16

var axis_flip = false # This is to make diagonal movement 'slightly' less tedious

func _process(delta):
	var dir : Vector2 = get_input_dir()
	if dir != Vector2.ZERO:
		var target : Vector2 = position + dir * tile_size
		$Tween.interpolate_property(self, "position", position, target, 1.0 / speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

func _on_Tween_tween_started(object, key):
	set_process(false)
 
func _on_Tween_tween_completed(object, key):
	set_process(true)

func get_input_dir() -> Vector2:
	var dir = Vector2()
	if not axis_flip:
		dir.y = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
	if dir.y == 0:
		dir.x = (int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")))
	if axis_flip and dir.x == 0:
		dir.y = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
		
	if dir != Vector2.ZERO:
		axis_flip = not axis_flip
 
	return dir
