# Adventure Game Template

An ugly little adventure for Godot **4.5**, ready for your ideas. Walk around,
read clues, collect items, activate switches, and open doors. The example is
short and much too easy. Making a good game is your job.

Download this repo as a ZIP, unzip it, and import `project.godot` in Godot.
Press **F6 only when testing a complete room**; press **F5** to play the game
with its HUD, room changes, and save buttons. Use F5 for the example walkthrough.

## Play it first

WASD or arrow keys move. Walk near an object; its **E** prompt appears.
Press E to interact. Read the sign, collect the key, turn on the switch, and
use the door. Room two has a return door and an exit. Save, Load, and Restart
are at the top. Restart starts fresh but keeps your last manual save.

## Your mission — no code needed

1. Open `scenes/levels/Room1.tscn`. Select **Entities/Player** and change
   **Move Speed** and **Interaction Distance**. Tune by playing.
2. Select **Entities/Sign**. Write a new **Message** and **Display Name**.
3. Select **Entities/Key**. Change **Item Id** to `battery`. On **Door**, set
   **Required Item** to `battery`. IDs must match exactly; they aren't labels.
4. Drag your PNGs into `assets/`. Drop one onto each object's **Picture** field.
   Player has a Picture field too. Use roughly 48×48 images for objects and
   player art; larger images display at their original size (player at 65%).
5. Duplicate an object with Cmd+D. Move it. Choose its **Behavior** and fill in
   the matching fields below. Everything connects itself.
6. Duplicate a whole room file in the FileSystem dock. Keep **Entities/Player**
   and **Spawn**. Move the Spawn marker to set the entry point. On a door, select
   your new file in **Destination Room**. Every entry uses that room's Spawn.
7. Change Main → UI → HUD → **Mission** to explain your game. Playtest it!

Rooms open as visible layouts in the editor. Walls are StaticBody2D nodes:
when resizing one, change both its Art polygon and CollisionShape2D.
For a background image, add a Sprite2D before Walls and Entities in the room.
Use **F5**, not a loose Interactable scene, for meaningful interaction tests.

## Choose an interaction

| Behavior | Fill in | What happens |
|---|---|---|
| Inspect | Message | Shows a clue or one line of dialogue |
| Pickup | Item Id, Message | Adds that unique item and hides this pickup |
| Switch | Flag Id, Message | Turns that named flag on permanently |
| Door | Destination Room, Message | Opens another room |
| Finish | Message | Stops movement/interactions and shows your ending |
| Custom | The marked function in the script | Runs your new interaction logic |

Every behavior can require an item, a flag, or both. Blank requirements mean
none. **Locked Message** explains what's missing. Keys are never consumed.
**Once Only** hides an object after using it; leave it off for reusable doors.
Switches set flags on; they don't toggle off. Items have no quantities.

## Where things live

```
Main
├── Managers
│   └── RoomManager       loads rooms; saves/loads progress
├── WorldRoot             holds one room at a time
└── UI
    └── HUD               mission, message, items, buttons

Room1 (or your room)
├── Floor / RoomLabel
├── Walls
├── Entities
│   ├── Player            walking + nearest-object prompt
│   └── your objects     instances of Interactable.tscn
└── Spawn                 where the player enters
```

The folders match those jobs: `scenes/entities`, `scenes/levels`,
`scenes/managers`, `scenes/ui`, `autoload`, and `assets`.
`Globals` holds items, flags, and used objects. `SignalBus` is a bulletin board:
objects post messages or request a room; the HUD and RoomManager listen.

## When you need a new behavior

Try the Inspector options first. For something new, duplicate
`scenes/entities/Interactable.gd` in the FileSystem dock, attach the copied
script to your special object's root, select **Custom**, and find:

```gdscript
func custom_interaction() -> void:
    # PUT INTERACTION LOGIC HERE.
    pass
```

Replace `pass` with your logic (use tabs in Godot). For example,
`Globals.flags.append("machine_repaired")` lets an ordinary door require
`machine_repaired`. The template already checks requirements, shows Message,
updates the HUD, and handles Once Only. Keep those parts.
Don't edit Main or Player just to add a new interaction.

## Save rules and limits

Save is manual. It records the current room, player position, items, flags,
used objects, and whether the adventure is complete. Load restores those facts.
Progress also survives walking between rooms without saving.
Renaming room files or object nodes can invalidate old saves: start fresh after
reorganizing your project. Custom moving objects need extra save code.

On the web, saves belong to this browser and website. Clearing website data
removes them. This slice does not include branching Ink dialogue, battles,
audio, pause menus, automatic checkpoints, or an inventory grid. Inspect works
for short NPC lines. Interaction uses distance, not line of sight; keep objects
away from the other side of thin walls.

## Playtest checklist

- Can someone find the first clue without you explaining it?
- Does the door refuse entry before its requirements are met?
- Can each pickup be collected only once, even after returning to the room?
- Does Save → move → Load restore the saved position and items?
- Can the player finish and Restart successfully?
- Do labels and messages fit, and can the game be played in a browser?

## Publish

Project → Export → **Web**. Install the Godot 4.5 export templates if asked.
Create an `html_export` folder, export `index.html` there, and upload the whole
folder to your web game host. Don't open the HTML by double-clicking it; it
needs a web server. The preset uses Compatibility and no threads.

Godot references: [Inspector exports](https://docs.godotengine.org/en/4.5/tutorials/scripting/gdscript/gdscript_exports.html),
[CharacterBody2D](https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html).
