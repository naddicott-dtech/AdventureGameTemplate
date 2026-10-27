extends Control
@export_multiline var mission := "YOUR MISSION: Replace the art. Change the clues. Build another room."
@export var room_manager: Node

func _ready() -> void:
	$Mission.text = mission
	SignalBus.message.connect(_show_message)
	SignalBus.state_changed.connect(_refresh)
	$Save.pressed.connect(func(): room_manager.save_game())
	$Load.pressed.connect(func(): room_manager.load_game())
	$Restart.pressed.connect(room_manager.restart)
	_refresh()

func _show_message(text: String) -> void:
	$Message.text = text

func _refresh() -> void:
	$Inventory.text = "Items: " + (", ".join(Globals.items) if not Globals.items.is_empty() else "none")
	$Status.text = "COMPLETE — Restart to play again" if Globals.finished else "WASD / arrows: walk    E: interact"
