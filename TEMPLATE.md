# Adventure template — quick reference

Godot 4.5, pure GDScript, Compatibility, browser export. Two top-down rooms.
Scene tree and folders follow Narrative's Main/Managers/WorldRoot/UI layout.

## Knobs

- Player: move_speed (float), interaction_distance (float), picture (Texture2D).
- Interactable: display_name (String), behavior (enum), message (multiline String),
  picture (Texture2D), required_item/required_flag (String IDs), locked_message,
  item_id/flag_id (String IDs), once_only (bool), destination_room (scene path).
- RoomManager: starting_room (scene path), world_root (prewired Node).
- HUD: mission (multiline String), room_manager (prewired Node).
- Room Spawn: editor position. Walls: art polygon + collision rectangle.

## Blocks and roles

Duplicate Interactable.tscn instances or whole room files. Keep room's
Entities/Player and Spawn. Artist: Picture exports/assets. Writer: messages,
clues, mission. Designer: room layout, requirements, movement/range knobs.
Programmer: custom_interaction() in a copied Interactable.gd, behavior CUSTOM.

## Flow and ownership

Player finds nearest visible interactable → E calls interact() → requirements
checked → enum branch changes Globals or emits room_requested → deferred
RoomManager swap. SignalBus.message → HUD; state_changed → inventory/status.
Globals: items, flags, used_objects, finished. Items/flags are unique strings.
Used IDs = room scene path + object node path. Preserve names for old saves.
RoomManager owns manual JSON save/load (room, position, those four state fields).
No generalized stats framework. No automatic Ink integration.

## Common tweaks

Key→battery: change pickup item_id AND door required_item. More locks: duplicate
switch, set a different flag_id, match required_flag. New room: duplicate room,
move Spawn, choose file on Door. New art: set Picture; size with Sprite2D scale.
Custom action: copied script, custom_interaction(); standard flow still handles
requirements, message, once_only, HUD update. Tests live outside student repo.
