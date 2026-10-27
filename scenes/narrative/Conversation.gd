extends Control
# The room stays alive behind this panel. Only its processing is suspended.
# Narrative's unchanged loader/runtime handle Ink; this file handles NPC flow.
@export var world_root: Node
var at_end := false
var failed := false
# Choice tags collect here; only Return commits them to the adventure.
var pending_flags: Array[String] = []
var story: InkStory
var npc: Node
var previous_process_mode: Node.ProcessMode
var loader := NarrativeStoryLoader.new()

func _ready() -> void:
	hide()
	SignalBus.conversation_requested.connect(open)
	loader.failed.connect(_show_error)
	$Panel/Rows/Next.pressed.connect(advance)
	$Panel/Rows/Cancel.pressed.connect(cancel)

func open(character: Node) -> void:
	if Globals.in_conversation or Globals.finished:
		return
	npc = character
	at_end = false
	failed = false
	pending_flags.clear()
	Globals.in_conversation = true
	previous_process_mode = world_root.process_mode
	world_root.process_mode = Node.PROCESS_MODE_DISABLED
	SignalBus.state_changed.emit()
	show()
	$Panel/Rows/Speaker.text = npc.display_name
	$Panel/Rows/Portrait.texture = npc.conversation_portrait
	$Panel/Rows/Portrait.visible = npc.conversation_portrait != null
	$Panel/Rows/Text.text = ""
	_clear_choices()
	$Panel/Rows/Next.text = "Next"
	$Panel/Rows/Next.disabled = false
	# Runtime is the same pinned pure-GDScript engine as Narrative's template.
	story = loader.load_from_path(npc.story_file, get_tree().root.get_node("__InkRuntime"))
	if story != null and not failed:
		advance()

func advance() -> void:
	if not Globals.in_conversation or failed:
		return
	if at_end:
		_finish()
		return
	if story == null or not story.current_choices.is_empty():
		return
	if story.can_continue:
		var text := story.continue_story()
		if failed:
			return
		if not _read_tags(story.current_tags):
			return
		$Panel/Rows/Text.text = text.strip_edges()
	_show_choices_or_end()

func choose(index: int) -> void:
	if not Globals.in_conversation or failed or story == null:
		return
	if index < 0 or index >= story.current_choices.size():
		return
	_clear_choices()
	story.choose_choice_index(index)
	advance()

func _show_choices_or_end() -> void:
	_clear_choices()
	for index in story.current_choices.size():
		var button := Button.new()
		button.text = story.current_choices[index].text.strip_edges()
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 44
		button.pressed.connect(choose.bind(index))
		$Panel/Rows/ChoicesScroll/Choices.add_child(button)
	at_end = not story.can_continue and story.current_choices.is_empty()
	$Panel/Rows/Next.disabled = not story.current_choices.is_empty()
	$Panel/Rows/Next.text = "Return to room" if at_end else "Next"

func _read_tags(tags: Array) -> bool:
	# Inky: Thanks for helping! # flag: helped_npc
	# IDs use letters, digits and underscores, matching Required Flag exactly.
	for raw_tag in tags:
		var tag := str(raw_tag).strip_edges()
		if tag.begins_with("flag:"):
			var flag := tag.trim_prefix("flag:").strip_edges()
			if not flag.is_valid_identifier():
				_show_error("Invalid flag tag: " + tag + ". Use flag: helped_npc (letters, digits, underscores; no spaces).")
				return false
			if flag not in pending_flags:
				pending_flags.append(flag)
		elif tag.begins_with("flag"):
			_show_error("Malformed flag tag: " + tag + ". Use flag: helped_npc.")
			return false
		elif tag.begins_with("@"):
			_show_error("This NPC player supports text, choices and flag: tags, not Narrative @ cues. Remove: " + tag)
			return false
	return true

func _finish() -> void:
	for flag in pending_flags:
		if flag not in Globals.flags:
			Globals.flags.append(flag)
	# Completion is explicit and Inspector-driven. Cancelling grants nothing.
	if npc.completion_flag != "" and npc.completion_flag not in Globals.flags:
		Globals.flags.append(npc.completion_flag)
	if npc.once_only:
		Globals.used_objects.append(npc.object_id)
		npc.hide()
	_close()

func cancel() -> void:
	if Globals.in_conversation:
		_close()

func _close() -> void:
	_clear_choices()
	hide()
	story = null
	pending_flags.clear()
	npc = null
	world_root.process_mode = previous_process_mode
	Globals.in_conversation = false
	SignalBus.state_changed.emit()
	SignalBus.message.emit("Back to exploring. Your progress is intact.")

func _show_error(message: String) -> void:
	failed = true
	_clear_choices()
	$Panel/Rows/Text.text = message + "\nCancel to return to the room and fix the story in Inky, re-export its JSON, and check the NPC's Story File."
	$Panel/Rows/Next.disabled = true

func _clear_choices() -> void:
	for button in $Panel/Rows/ChoicesScroll/Choices.get_children():
		$Panel/Rows/ChoicesScroll/Choices.remove_child(button)
		button.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		cancel()
		get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	# The runtime outlives this panel. Detach its listener when Main closes.
	var runtime := get_tree().root.get_node_or_null("__InkRuntime")
	if runtime != null and runtime.exception_raised.is_connected(loader._on_runtime_exception):
		runtime.exception_raised.disconnect(loader._on_runtime_exception)
