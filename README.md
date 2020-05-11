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
`elm make src/Main.elm --output=elm.js`
open `index.html` in browser



# Referenties
- [elm](elm-lang.org)
