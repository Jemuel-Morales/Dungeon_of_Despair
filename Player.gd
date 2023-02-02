extends KinematicBody2D

export var SPEED : float = 90
export var starting_direction : Vector2 = Vector2(0, 1)

#parameters/Idle/blend_position
onready var animation_tree = $AnimationTree
onready var state_machine = animation_tree.get("parameters/playback")
onready var fps_label = $fps_label

func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(_delta):
	player_movement()
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func player_movement():
	var input_direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	update_animation_parameters(input_direction)
	input_direction.normalized() #prevent speed doubled
	move_and_slide(input_direction * SPEED)
	
	if($TorchTimer.time_left <= 0):
		$Light2D.energy = rand_range(1.2, 2)
		$TorchTimer.start(0.2)
	
	if(input_direction != Vector2.ZERO):
		state_machine.travel("Walk")
		if($Timer.time_left <= 0):
			$AudioStreamPlayer2D.pitch_scale = rand_range(0.8, 1.2)
			$AudioStreamPlayer2D.play()
			$Timer.start(0.5)
	else:
		state_machine.travel("Idle")
		$AudioStreamPlayer2D.stop()
		$Timer.stop()
	
func update_animation_parameters(move_input: Vector2):
	
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
