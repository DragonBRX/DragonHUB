# DragonHUB

Código-fonte Lua organizado e carregado diretamente pelo Roblox.

## Carregamento

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonBRX/DragonHUB/main/DragonHUB.lua"))()
```

`DragonHUB.lua` abre o loader, que identifica Blox Fruits e seleciona o modo escolhido pelo usuário.

## Estrutura

- `DragonHUB.lua`: ponto de entrada público.
- `DragonHUB-Loader.lua`: identifica o jogo e carrega o manifesto.
- `Games/BloxFruits/Links.lua`: reúne somente os arquivos Lua realmente executados.
- `Games/BloxFruits/HubLayout.lua`: descreve abas e controles da interface.
- `Games/BloxFruits/Source/UI.lua`: seletor inicial de modo.
- `Games/BloxFruits/Source/HubUI.lua`: interface do modo HUB.
- `Games/BloxFruits/Source/Runtime.lua`: implementação real das funções do script.
- `Games/BloxFruits/Source/Modes`: inicializadores dos modos HUB e AUTOMÁTICO.

## Código-fonte

O projeto não usa criptografia, obfuscação, arquivos gerados por Python ou módulos vazios. A lógica real está em Lua e pode ser lida diretamente no repositório.

Os antigos arquivos de `Source/Functions` e `Source/Modules` foram removidos porque continham apenas adaptadores genéricos. Eles não eram implementações independentes: todos encaminhavam a execução de volta para callbacks definidos em `Runtime.lua`.

`Runtime.lua` foi preservado como a fonte funcional principal porque suas rotinas compartilham estado, serviços e funções auxiliares. Os blocos comprimidos foram reorganizados com quebras de linha, mantendo a mesma sequência de tokens Lua.

## Modos

- `HUB`: carrega o layout, a interface e registra os callbacks reais do runtime.
- `AUTOMATIC`: executa diretamente o runtime com a automação configurada.

Nenhum dos modos depende de Python. Todos os arquivos necessários para execução estão publicados como Lua.
