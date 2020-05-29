# Ultimate Tic Tac Toe (UTTT)
Recursieve versie van boter kaas en eieren

## Voorstel
### Randvoorwaarden
De volgende dingen moeten duidelijk zijn voor het voorstel:
- Onderwerp van jouw individuele project
    - Belangrijkste features voor jou project
- Persoonlijke leerdoelen (ten minste een op elk vlak)
	- technisch
	- persoonlijk

Randvoorwaarden aan projectonderwerp:
1.	Alles wat je geleerd hebt toepassen: UI, Service, Domein, Persistentie(DB of session), CICD, MVC
2.	TDD ontwikkelen, dus onderwerp wat niet alleen CRUD heeft, maar ook logica
3.	Niet te klein, niet te groot. Niet alleen programmeren: requirements, tester, backlog management

Overzicht van belangrijkste features die het product moet hebben met motivatie over waarom deze en niet andere.

### Onderwerp
### Technisch leerdoel
- leren functioneel programmeren met behulp van elm


### Persoonlijk leerdoel
- planning: georganiseerd aan de slag gaan: problemen opdelen, requirements opstellen en uitwerken

## Uitwerking
### Functionaliteit
In het uiteindelijke resultaat moet sowieso het volgende aanwezig zijn: (in implementatie volgorde)
- bestaande versie van boter kaas en eieren koppelen zodat je via nodejs server kan spelen
- UTTT in front-end implementeren
- UTTT compatible maken met nodejs backend
- statistieken pagina om te zien welke games er allemaal gespeelt zijn
- meekijkfunctionaliteit (voor mensen die een spel openen die al bezet is)

Mocht er tijd over zijn dan:
- een UTTT AI om tegen te spelen (front-end)
- statistieken over games tegen AI
- Tutorial hoe te spelen



## Planning
week 1:
- simpele applicatie in elm bouwen om elm te leren kennen
- proberen middleware in te bouwen in de root voor proof of concept, werkt dat niet, dan opnieuw beginnen met andere functionele taal
    - pagina in module zetten zodat hij op meerdere plekken gebruikt kan worden
    - nodejs server opzetten om requests op te vangen en te printen
    - middleware maken die state naar server stuurt bij elke update
    - volger pagina maken

week 2:
- Ultimate tic tac toe requirements opstellen, zie trello
- ci opzetten
- tic tac toe bouwen

week 3:
- Ultimate tic tac toe functioneel afmaken en uiterlijk bruikbaar maken
- testing opzetten

Voor verdere planning, zie trello


### Vragen
- is elm enige architectuur om dit op te lossen? ->
	Main stream platformem : Vue + Vuex. React met Redux. 
	Obscuurdere platformen: purescript, ocaml->reasonml (, cyclejs)
- wat zijn restricties van elm? ->
	nieuwe functionaliteiten kunnen beperkt gebouwd worden
	beschikbare packages zijn gelimiteerd, selecte groep van mensen kan packages maken


# Documentation

## Install
`npm install`

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