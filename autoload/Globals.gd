extends Node
# Explicit adventure facts. Items are unique IDs, not quantities.
var items: Array = []
var flags: Array = []
var used_objects: Array = []
var finished := false

func reset() -> void:
	items.clear()
	flags.clear()
	used_objects.clear()
	finished = false
	SignalBus.state_changed.emit()
