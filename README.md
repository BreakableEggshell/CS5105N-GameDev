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
