
# DEVLOG

## Day 1 - Project setup and first combat loop

### Done
- Created GitHub repository
- Created Godot project
- Defined initial folder structure
- Created first battle scene
- Added basic UI:
  - Player HP label
  - Enemy HP label
  - Status label
  - Attack button
  - Guard button
- Implemented minimal combat loop
- Implemented enemy automatic turn
- Implemented victory/defeat state
- Disabled buttons after battle end

### Problems encountered
- Confusion about Godot scene hierarchy and parent/child nodes
- UI/background sizing issues
- Buttons appeared unresponsive because the game was not in proper input mode during testing

### Decisions made
- Engine: Godot
- Language: GDScript
- Scope kept intentionally minimal
- Placeholder visuals are acceptable
- Project should prioritize clean structure from the start

### Current state
- Playable 1v1 battle prototype exists
- Player can Attack and Guard
- Enemy responds automatically
- Battle can end in victory or defeat

### Next steps
- Add Restart button
- Create `reset_battle()` function
- Improve code organization slightly
- Commit and tag first milestone
