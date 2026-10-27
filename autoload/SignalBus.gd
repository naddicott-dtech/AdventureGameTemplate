extends Node
# A small bulletin board. Objects announce; the room manager and HUD listen.
signal message(text: String)
signal state_changed
signal room_requested(path: String)
signal finished(text: String)

signal conversation_requested(npc: Node)
