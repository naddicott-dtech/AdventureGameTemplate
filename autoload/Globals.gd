extends Node
# Explicit adventure facts. Items are unique IDs, not quantities.
var items: Array = []
var flags: Array = []
var used_objects: Array = []
var finished := false
# Transient: conversations are not saved halfway through.
var in_conversation := false

func reset() -> void:
	items.clear()
	flags.clear()
	used_objects.clear()
	finished = false
	in_conversation = false
	SignalBus.state_changed.emit()
