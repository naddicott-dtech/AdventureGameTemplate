extends CharacterBody2D
@export_range(20, 600, 10) var move_speed := 230.0
@export_range(20, 200, 5) var interaction_distance := 90.0
@export var picture: Texture2D
var nearby: Node2D

func _ready() -> void:
	add_to_group("player")
	if picture != null:
		$Sprite2D.texture = picture

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * move_speed
	if Globals.finished:
		velocity = Vector2.ZERO
	move_and_slide()
	nearby = null
	var closest := interaction_distance
	for object in get_tree().get_nodes_in_group("interactables"):
		if not object.is_visible_in_tree():
			continue
		var distance := global_position.distance_to(object.global_position)
		if distance < closest:
			closest = distance
			nearby = object
	$Prompt.text = "E: " + nearby.display_name if nearby != null and not Globals.finished else ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and is_instance_valid(nearby):
		nearby.interact()
		get_viewport().set_input_as_handled()
