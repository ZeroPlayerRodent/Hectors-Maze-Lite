# Hectors-Maze-Lite
Lightweight version of [Hector's Maze](https://github.com/ZeroPlayerRodent/Hectors-Maze), designed specifically to be built and run on Raspberry Pi computers.

(This game was tested and confirmed to work on Raspberry Pi 3 and Raspberry Pi 4 systems.)

## What's different
This version of Hector's Maze has simpler graphics, and doesn't have any audio.

## How to build from source
1. Install [SBCL](https://www.sbcl.org/) and the [CLX](https://packages.debian.org/stable/lisp/cl-clx-sbcl) library.
2. Clone this repo and navigate to the directory containing `build.lisp`.
3. Build the game by loading `build.lisp` in SBCL.
4. Run the game by typing `./hectors-maze` in the terminal.

You can change the size of the maze by passing a command-line argument to the program.

The sizes that are available are `small`, `medium` or `large`.

Example: type `./hectors-maze large` to start the game with a large maze.
