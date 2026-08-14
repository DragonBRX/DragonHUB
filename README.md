# DragonHUB

Carregamento:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/DragonHUB.lua"))()
```

O `DragonHUB.lua` abre o `DragonHUB-Loader.lua`. O Loader identifica a experiência pelo `GameId` ou pelos `PlaceId` configurados e abre o manifesto correspondente.

Atualmente o registro contém Blox Fruits com os IDs dos três Seas. Jogos com apenas um mapa podem usar somente um `PlaceId`; jogos com mundos diferentes podem registrar vários IDs.

Todo o código executado fica aberto e legível em `Games/BloxFruits/Source`. O manifesto `Games/BloxFruits/Links.lua` aponta diretamente para essa pasta, sem wrappers de criptografia ou ofuscação.

No modo AUTOMÁTICO, os módulos agrupados são carregados antes do runtime. No modo HUB, `Games/BloxFruits/Functions.lua` fornece um link individual para cada botão e somente o módulo exato da função ativada é carregado.

A interface HUB é carregada antes do runtime por `Source/HubUI.lua`. Ela apresenta abas por categoria, toggles deslizantes, sliders de toque e mouse, botões e seletores. As escolhas feitas durante o carregamento são aplicadas quando o runtime registra os callbacks correspondentes.

Esta versão não contém a antiga pasta `Encrypted` nem o gerador `build.py`. Alterações feitas nos arquivos de `Source` são carregadas diretamente pelo HUB.

O modo HUB utiliza somente a interface própria do DragonHUB. O runtime funciona como adaptador sem interface, não cria janela secundária, não usa bibliotecas visuais externas, não carrega ícones de outros hubs e mantém os títulos sem emojis.

Os seletores abrem uma lista flutuante com rolagem e seleção única. Isso permite escolher diretamente frutas, materiais, armas, barcos e outras opções sem percorrer os valores com vários cliques.

O menu de frutas consulta o estoque com segurança e permite atualizar a lista, comprar a fruta básica ou Mirage selecionada, escolher qualquer fruta no seletor do sniper e ativar a compra automática quando ela aparecer. A compra básica usa a mesma assinatura confirmada no código anterior: `PurchaseRawFruit`, nome selecionado e `false`.

`Auto Random Fruit` envia a tentativa de giro imediatamente ao ser ativado e repete a chamada original a cada 0,1 segundo. `Random Fruit Now` executa uma tentativa direta sem depender do toggle. Regras ou respostas restantes são decididas pelo servidor do jogo, sem cálculo local de dinheiro ou espera inicial no DragonHUB.
