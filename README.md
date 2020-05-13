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

Voor verdere planning, zie trello


### Vragen
- is elm enige architectuur om dit op te lossen? ->
	Main stream platformem : Vue + Vuex. React met Redux. 
	Obscuurdere platformen: purescript, ocaml->reasonml (, cyclejs)
- wat zijn restricties van elm? -> nieuwe functionaliteiten kunnen beperkt gebouwd worden


# Documentation

## Install
`npm install`
`npm run build`

## Run
`npm run start`
open `index.html` in browser

## Protocol
As clients should not be able to alter the gamestate outside the rules, it should be managed by the server.
It is impossible to store the state in elm, because it is a functional language.
Therefore, consider the node server a middleman that stores the gamestate and handles the socket: `Client <--> Node server <--> Backend`
Everytime a message from the client comes in, the current gamestate stored in nodejs is combined with the client request and passed to the backend.

Client --> Backend
- Place mark : {'type': 'PlaceMark', 'message': Ttt.Pos}
- Send chat message : {'type': 'ChatMessage', 'message': String}

Backend --> Client
- Update gamestate : {'type': 'UpdateGamestate', 'message': Ttt.Gamestate}
- Error : {'type': 'ServerMessage', 'message': String}
- Receive chat message : {'type': 'ChatMessage', 'message': String}

Gamestate information:
- board: whether marks are placed on each square
- who's turn it is
- winner: whether the game is won by somebody or is ongoing

Note that both the client and the backend are written in elm, so the code for the game is reused.



## Dependencies
- [elm](elm-lang.org)
- node