# Flutter Chess App

A complete chess game implementation in Flutter with AI opponent.

## Features

- **8x8 Chess Board**: Standard chess setup with all pieces
- **Drag & Drop Interface**: Intuitive piece movement with drag and drop
- **Valid Move Highlighting**: Green circles show valid moves for selected pieces
- **AI Opponent**: Computer plays as black pieces with intelligent move selection
- **Game State Management**: Tracks checkmate, stalemate, and draw conditions
- **Turn Indicator**: Shows whose turn it is (User vs AI)
- **Game End Dialogs**: Displays result when game ends
- **Responsive UI**: Clean, modern interface with Flutter best practices

## Game Rules

- Standard chess rules apply
- User plays as white pieces
- AI plays as black pieces
- All standard moves including castling and en passant
- Automatic pawn promotion to queen

## How to Play

1. **Select a Piece**: Tap on any of your pieces (white)
2. **See Valid Moves**: Green circles will appear showing valid moves
3. **Make a Move**: Tap a valid move square or drag the piece to the destination
4. **AI Turn**: The AI will automatically make its move after you move
5. **Game End**: The game ends with checkmate, stalemate, or draw

## Architecture

The app is structured for easy extension:

- **Models**: `Piece`, `Position`, `Move` - Core data structures
- **Game Logic**: `ChessGame` - Handles all game rules and state
- **AI**: `ChessAI` - Pluggable AI system (currently SimpleChessAI)
- **UI**: `ChessBoard`, `ChessGameScreen` - Interactive game interface

## Future Extensions

The code is designed to easily support:
- Multiplayer (human vs human)
- Game history and replay
- Different AI difficulty levels
- Save/load games
- Online multiplayer
- Tournament mode

## AI Implementation

Currently uses `SimpleChessAI` which:
- Prefers capturing pieces
- Controls center squares
- Avoids moves that put own king in check
- Falls back to random valid moves

The AI system is abstracted, making it easy to integrate stronger engines like Stockfish.

