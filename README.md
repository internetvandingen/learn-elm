# Ultimate Tic Tac Toe (UTTT)
Learn Elm by building the recursive version of tic-tac-toe.

## Install
After cloning, run `npm install`

## Directory structure
- `build`: source files copies and compiled files, deployable directory
- `elm-stuff`: elm stuff that is used to compile to javascript
- `node-modules`: node modules
- `src`: directory with all source files
	- `client`: client files, this directory gets copied recursively to `build`
- `tests`: directory with all test files

## Testing
Package [`elm-explorations/test`](https://package.elm-lang.org/packages/elm-explorations/test/latest/) is used for unit testing.

## Scripts
Run a script called `test` with `npm run test`
- `build`: compiles elm sources and copies `server.js` and everything in `client/` to the `build/` directory
- `clean`: removes everything from the `build/` directory
- `test`: runs elm tests defined in `tests/`
- `start`: runs `clean`, `build` and `test` scripts. Then starts a node server from the `build/` directory. Go to `localhost:8080` to acces the application.

## Protocol
As clients should not be able to alter the gamestate outside the rules, it should be managed by the server.
The elm code on the backend keeps track of the gamestate, but it cannot handle communication over http.
For this I use node, consider the node server a middleman that handles the socket connections: `Client <--> Node server <--> Backend`
Everytime a message from the client comes in, the client number is combined with the client request and passed to the backend.
In short, node injects e.g. "player":1 into the json before it is passed to the backend

Client --> nodejs websocket --> Backend
- Request update : {'type': 'UpdateRequest', message: ''}
- Place mark : {'type': 'PlaceMark', 'message': Uttt.Pos}
- Send chat message : {'type': 'ChatMessage', 'message': String}

Backend --> nodejs websocket --> Client
- Update gamestate : {'type': 'UpdateGamestate', 'message': Uttt.Gamestate}
- Error : {'type': 'ServerMessage', 'message': String}
- Receive chat message : {'type': 'ChatMessage', 'message': String}

Gamestate information:
- board: whether marks are placed on each square
- turn: who's turn it is
- winner: whether the game is won by somebody or is ongoing

Note that both the client and the backend are written in elm, so the code for the game can be reused.



## Dependencies
- [elm](https://elm-lang.org)
	- elm-explorations/test: 1.2.2
	- Bernardoow/elm-alert-timer-message: 1.0.1
- node
	- websocket
	- http
	- fs
	- path
