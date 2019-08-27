# MapGen2D
Yet another attempt at map gen, taking advantage of autotiles

Using some assets from https://www.kenney.nl/ to attempt some automap generation with character and hopefully mob movement.
Some assets will have been extended slightly to create full autotile sets, but still trying to stay in the Kenney style.

### Running the demo

Controls in this demo are `W` `A` `S` `D` or the arrow keys.
To open the inventory press `E`.
To open a chest press `Space`.
To close the inventory, or close a chest after opening, press `E`.
Move into a door to 

## General 'Design' Approach

This code is a untested prototype and as such may contain many, _many_ bugs.

The starting scene is Game.tscn ([Game.gd](Game.gd)) but isn't really used past the world generation and switching to the primary generated scene.

The World and Player scenes are created by WorldGenerator.tscn ([WorldGenerator.gd](autoload/WorldGenerator.gd)). The player is simply an instance of Player.tscn ([Player.gd](player/Player.gd)).

#### Town Generation

The town generation ([TownGen.gd](map/TownGen.gd)) begins with populating a set of timemaps using noise from the built-in OpenSimplexNoise generator to select the tiles. The generation relys on auto-tiling to be setup to correct tile edges. Point's of interest are then chosen using a noise function. Point's of interest are then assessed to determine if a house could be placed at that location and if-so a house template is chosen using seed randomisation.

#### House Externals

Houses are merged into the town map from the house templates ([House_3x3.tscn](map/structures/House_3x3.tscn), [House_5x5.tscn](map/structures/House_5x5.tscn)) which are basically scenes with the same-named tilemap layers as in the town scene (Base, Ground, Obstacles, Canopy). The templates can also contain instances of Doors which are part of a Gen_Portal node. The Gen_Portal node will have a script attached which will return some details that are placed in a table of portal descriptors. When the 'town' is returned, it is returned with a set of portal descriptors that are then used to create the interiors of the housesplaced in the town. 

#### House Internals

The portal descriptors returned from the town generation contain the details needed for generating the places the portals (Doorways) in the town will link to. The portal descriptor will contain a script that will build the inner spaces ([House_3x3/GenInterior.gd](map/structures/House_3x3/GenInterior.gd), [House_3x3/GenInterior.gd](map/structures/House_3x3/GenInterior.gd)), these places are also be created using templates for the rooms ([3x3 Kitchen](map/structures/House_3x3/rooms/Kitchen_01.tscn), [3x3 Bedroom](map/structures/House_3x3/rooms/Bedroom_01.tscn), [5x5 Kitchen](map/structures/House_5x5/rooms/Kitchen_01.tscn), [5x5 Bedroom](map/structures/House_5x5/rooms/Bedroom_01.tscn)).

#### Scenes

The world generation ultimately produces a library (a table) of PackedScenes. The scene transitions are managed by SceneChanger.tscn ([SceneChanger.gd](autoload/SceneChanger.gd)) which handles the screen fade-out, re-packing the current scene, loading the new scene, moving the player to the new scene, fixing the camera bounds to the limits of the new scene and finally performing the screen fade-in. The scene change is triggered by the player colliding with a door.

## Final note

I'll likely not do any more work on this directly (apart from bug fixes) though I may use this as a template for further development of a more complex project. If you find any bugs, or find this code useful, please let me know.
