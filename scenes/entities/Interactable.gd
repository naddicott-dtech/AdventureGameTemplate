extends Node2D
# Duplicate this scene, choose a Behavior, then fill in its Inspector fields.
enum Behavior { INSPECT, PICKUP, SWITCH, DOOR, FINISH, CUSTOM }
@export var display_name := "object"
@export var behavior: Behavior = Behavior.INSPECT
@export_multiline var message := "Put your clue here."
@export var picture: Texture2D
@export_group("Requirements (blank means none)")
@export var required_item := ""
@export var required_flag := ""
@export_multiline var locked_message := "Something is missing."
@export_group("Result")
@export var item_id := ""
@export var flag_id := ""
@export var once_only := false
@export_file("*.tscn") var destination_room := ""
var object_id := ""

func _ready() -> void:
	add_to_group("interactables")
	$Label.text = display_name
	if picture != null:
		$Sprite2D.texture = picture
	var room := get_parent().get_parent()
	object_id = room.scene_file_path + ":" + str(room.get_path_to(self))
	if object_id in Globals.used_objects:
		hide()

func can_use() -> bool:
	return (required_item == "" or required_item in Globals.items) and (required_flag == "" or required_flag in Globals.flags)

func interact() -> void:
	if Globals.finished or object_id in Globals.used_objects:
		return
	if not can_use():
		SignalBus.message.emit(locked_message)
		return
	match behavior:
		Behavior.INSPECT:
			pass # The message below is the whole action.
		Behavior.PICKUP:
			if item_id == "":
				SignalBus.message.emit("Set Item Id on " + display_name)
				return
			if item_id not in Globals.items:
				Globals.items.append(item_id)
		Behavior.SWITCH:
			if flag_id == "":
				SignalBus.message.emit("Set Flag Id on " + display_name)
				return
			if flag_id not in Globals.flags:
				Globals.flags.append(flag_id)
		Behavior.DOOR:
			if not ResourceLoader.exists(destination_room):
				SignalBus.message.emit("Set a valid Destination Room on " + display_name)
				return
			SignalBus.room_requested.emit(destination_room)
		Behavior.FINISH:
			Globals.finished = true
			SignalBus.finished.emit(message)
		Behavior.CUSTOM:
			custom_interaction()
	if behavior == Behavior.PICKUP or once_only:
		Globals.used_objects.append(object_id)
		hide()
	SignalBus.message.emit(message)
	SignalBus.state_changed.emit()

func custom_interaction() -> void:
	# PUT INTERACTION LOGIC HERE.
	# Select CUSTOM in the Inspector to run this block.
	# Example: Globals.flags.append("machine_repaired")
	# For a different custom object, duplicate this script and attach the copy
	# to that object's root. Main, movement, and the HUD need no changes.
	pass
