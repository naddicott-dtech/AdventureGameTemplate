extends Node
@export var world_root: Node
@export_file("*.tscn") var starting_room := "res://scenes/levels/Room1.tscn"
var current_room := ""

func _ready() -> void:
	SignalBus.room_requested.connect(_request_room)
	change_room(starting_room)

func _request_room(path: String) -> void:
	# Finish the interaction before removing its room.
	change_room.call_deferred(path)

func change_room(path: String) -> bool:
	if Globals.in_conversation:
		return false
	var scene = load(path)
	if not scene is PackedScene:
		SignalBus.message.emit("Cannot open room: " + path)
		return false
	var room = scene.instantiate()
	if not room.has_node("Entities/Player") or not room.has_node("Spawn"):
		room.free()
		SignalBus.message.emit("Room needs Entities/Player and Spawn.")
		return false
	for old in world_root.get_children():
		world_root.remove_child(old)
		old.queue_free()
	world_root.add_child(room)
	room.get_node("Entities/Player").position = room.get_node("Spawn").position
	current_room = path
	SignalBus.state_changed.emit()
	return true

func restart() -> void:
	if Globals.in_conversation:
		return
	Globals.reset()
	change_room(starting_room)
	SignalBus.message.emit("Fresh start. Find the key and turn on the switch.")

func save_game(path := "user://adventure_save.json") -> void:
	if Globals.in_conversation:
		return
	var player = world_root.get_child(0).get_node("Entities/Player")
	var data := {"room": current_room, "position": [player.position.x, player.position.y], "items": Globals.items, "flags": Globals.flags, "used": Globals.used_objects, "finished": Globals.finished}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		SignalBus.message.emit("Could not save this game.")
		return
	file.store_string(JSON.stringify(data))
	SignalBus.message.emit("Saved. Load returns to this spot.")

func load_game(path := "user://adventure_save.json") -> void:
	if Globals.in_conversation:
		return
	if not FileAccess.file_exists(path):
		SignalBus.message.emit("No save yet. Press Save first.")
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary or not data.get("items") is Array or not data.get("flags") is Array or not data.get("used") is Array or not data.get("position") is Array:
		SignalBus.message.emit("Save could not be read. Start a new game.")
		return
	if data.position.size() != 2 or not data.get("room") is String or not ResourceLoader.exists(data.room):
		SignalBus.message.emit("Saved room is missing. Start a new game.")
		return
	Globals.items = data.items
	Globals.flags = data.flags
	Globals.used_objects = data.used
	Globals.finished = data.get("finished", false)
	if change_room(data.room):
		world_root.get_child(0).get_node("Entities/Player").position = Vector2(data.position[0], data.position[1])
		SignalBus.message.emit("Loaded." if not Globals.finished else "Adventure complete! Restart to play again.")
