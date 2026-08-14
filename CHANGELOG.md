# DragonHUB — versão sem criptografia

Data: 14/08/2026

## Alterações

- Removida a árvore `Games/BloxFruits/Encrypted`.
- Removido o gerador de wrappers criptografados `build.py`.
- `Games/BloxFruits/Links.lua` agora carrega interface, runtime, modos e módulos diretamente de `Games/BloxFruits/Source`.
- `Games/BloxFruits/Functions.lua` agora carrega os 187 módulos individuais diretamente de `Source/Functions`.
- `generate_functions.py` foi atualizado para continuar gerando links abertos.
- Incluídos todos os 203 arquivos Lua legíveis necessários para o carregamento.

O comando de carregamento público permanece o mesmo depois que estes arquivos forem publicados na branch `main`.
