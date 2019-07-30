extends Node2D

export(float) var speed = 4.0
export(int) var tile_size = 16

var anim_sp_ratio = 0.5
var axis_flip = false # This is to make diagonal movement 'slightly' less tedious

onready var body : KinematicBody2D = $KinematicBody2D
onready var rays : Dictionary
var paused = false

func _ready():
	rays = {
		"0_1": $RayCastDown,
		"0_-1": $RayCastUp,
		"-1_0": $RayCastLeft,
		"1_0": $RayCastRight
	}
	$AnimationPlayer.playback_speed = speed * anim_sp_ratio

func _process(delta):
	if paused: return
	var dir : Vector2 = get_input_dir()
	if dir != Vector2.ZERO:
		var anim_name : String = str(int(dir.x)) + "_" + str(int(dir.y))
		if (rays[anim_name] as RayCast2D).is_colliding():
			anim_name += "_look"
		else:
			var target : Vector2 = position + dir * tile_size
			$Tween.interpolate_property(self, "position", position, target, 1.0 / speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		$AnimationPlayer.play(anim_name)

func _on_Tween_tween_started(object, key):
	set_process(false)
 
func _on_Tween_tween_completed(object, key):
	set_process(true)

func pause(p : bool = true):
	paused = p

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

func has_collided() -> bool:
	return true if body.get_collider() else false
