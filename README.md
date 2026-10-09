# CS5105N Game Dev Requirements

## Game Idea: Potion Knight

A 2D hack-and-slash platformer. Genre: hack and slash / 2D platformer.

## Week 1

Added the initial scene with a `Label` node displaying "Hello, World!" and an
`AnimatedSprite2D` playing a simple idle animation (looping 3-frame cycle from
a character spritesheet).

![alt text](/readme_screenshots/week1_helloworld.png)

## Week 2

Added a knight `CharacterBody2D` with idle, walk, jump, and fall animations,
controlled by a `StateMachine` node with one child node per state. Built a
small test level with a `TileMapLayer` and a `Camera2D` that follows the player.

Added a `Throw` state (E key) that throws a potion forward. The potion flies,
and on impact it shatters into `CPUParticles2D` shards and splash.

![alt text](/readme_screenshots/week2_throw.gif)

## Week 3

Added a HUD that shows the health and potion throwing cooldown.

Added a slime enemy that patrols back and forth, turning around at walls and
floor edges (using a `RayCast2D`). Touching it hurts the player, and it dies
after 3 potion hits. Falling out of the level also kills the player and
restarts the level.

Added a chest that opens when touched and loads the next level, plus 2 new
levels for a total of 3.

![alt text](/readme_screenshots/week3_levels.gif)

## Week 4

Added small particle effects using `CPUParticles2D`. When the player lands, a
puff of dust kicks out from both sides of their feet, and when a slime dies, it
bursts into a splash of green goo while its death animation plays.

![alt text](/readme_screenshots/week4_particles.gif)

## Week 5

Added a title screen (Start / Options / Exit) and a pause menu (Esc), with an
Options panel for music and SFX volume, fullscreen, and key rebinding. Added
background music and sound effects, routed through separate Music and SFX
audio buses. A short tutorial hint teaches the potion throw when the game
starts.

![alt text](/readme_screenshots/week5_menus.gif)

## Credits

**Music**
- Mexico Loop by Tim Beek

**Sound Effects**
- Chest open, enemy death, and HP recovery sounds from [Sound Effect Lab](https://soundeffect-lab.info/)

**Sprites**
- [Brackeys' Platformer Bundle](https://brackeysgames.itch.io/brackeys-platformer-bundle) by Brackeys (CC0)
  - Knight and slime by [analogStudios_](https://analogstudios.itch.io/)
  - World tileset by [RottingPixels](https://rottingpixels.itch.io/four-seasons-platformer-tileset-16x16free)
- [90 Free 16x16 Pixel Art Potions](https://alexkovacsart.itch.io/90-free-16x16-pixel-art-potions) by alexkovacsart
- [Animated HUD Pixel RPG](https://snoblin.itch.io/animated-hud-pixel-rpg) (hearts) by Snoblin
- [Sprout Lands Asset Pack](https://cupnooble.itch.io/sprout-lands-asset-pack) (chest) by Cup Nooble
- Menu buttons and pause/play icon made for this project

**Font**
- [Pixel Operator](https://www.dafont.com/pixel-operator.font) by Jayvee Enaguas (HarvettFox96), included in the Brackeys bundle
