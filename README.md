# Spieker
Meekijk functionaliteit in elm taal

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
Het onderwerp dat centraal staat is meekijkfunctionaliteit voor een website.
Hierbij doen we de volgende aannames:
- wordt in webapplicatie opgelost, niet via andere infrastructuur (screencapture)
- hoeft niet compatible te zijn met bestaande applicaties

### Technisch leerdoel
- leren functioneel programmeren met behulp van elm

### Persoonlijk leerdoel
- planning: georganiseerd aan de slag gaan: problemen opdelen, requirements opstellen en uitwerken

## Uitwerking
### Functionaliteit
In het uiteindelijke resultaat moet sowieso het volgende aanwezig zijn:
- voorbeeldpagina met formulieren en andere input elementen die gemanipuleerd kunnen worden door gebruiker
- user input of updates afvangen en doorsturen
- afgevangen data weergeven op een alleen-lezen pagina om mee te kijken

### Planning
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
- beginnen met bouwen

week 3:
- bouwen


### Vragen
- is elm enige architectuur om dit op te lossen? ->
	Main stream platformem : Vue + Vuex. React met Redux. 
	Obscuurdere platformen: purescript, ocaml->reasonml (, cyclejs)
- wat zijn restricties van elm? -> nieuwe functionaliteiten kunnen beperkt gebouwd worden




# Referenties
- [elm](elm-lang.org)
