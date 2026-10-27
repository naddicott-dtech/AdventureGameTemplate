# Small coding challenges

Start with the README's no-code mission. Then try these in order.

1. Make a locked object explain exactly what it needs. Find the requirement
   check in Interactable.gd. Keep item and flag IDs separate from visible text.
2. Make a custom machine set the `machine_repaired` flag. Copy Interactable.gd,
   attach it to the machine, choose Custom, and edit only custom_interaction().
   Set an ordinary door's Required Flag to `machine_repaired` to check your work.
3. Make a second custom machine need a tool first. Set Required Item in the
   Inspector; don't repeat the requirements check in your custom function.

Teacher check: before the tool, no flag is set; after the tool and interaction,
the flag exists and the door opens. A custom action still follows Once Only
and displays the object's Message, without changing Player or Main.
