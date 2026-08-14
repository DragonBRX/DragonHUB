# DragonHUB

Carregamento:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/DragonHUB.lua"))()
```

O `DragonHUB.lua` abre o `DragonHUB-Loader.lua`. O Loader identifica a experiência pelo `GameId` ou pelos `PlaceId` configurados e abre o manifesto correspondente.

Atualmente o registro contém Blox Fruits com os IDs dos três Seas. Jogos com apenas um mapa podem usar somente um `PlaceId`; jogos com mundos diferentes podem registrar vários IDs.

`Games/BloxFruits/Links.lua` permanece aberto porque contém somente IDs e links. A interface, os modos, o runtime e os módulos ficam na pasta `Encrypted`.

No modo AUTOMÁTICO, os módulos são carregados antes do runtime. No modo HUB, cada módulo de categoria é carregado apenas quando uma função daquela categoria é ativada pela primeira vez.
