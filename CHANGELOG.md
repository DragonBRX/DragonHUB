# Changelog

## 14/08/2026 — organização do código-fonte

- Removidos os wrappers genéricos de `Source/Functions` e `Source/Modules`.
- Removidos `Functions.lua`, `generate_functions.py` e `generate_hub_layout.py`.
- Simplificado `Links.lua` para listar apenas arquivos realmente executados.
- Simplificados os inicializadores dos modos HUB e AUTOMÁTICO.
- O HUB agora chama diretamente os callbacks reais registrados em `Runtime.lua`.
- Reformatados os blocos Lua comprimidos sem alterar sua sequência de tokens.
- Atualizados README e auditoria para descrever a arquitetura real.

## 14/08/2026 — remoção da árvore criptografada

- Removida a antiga árvore `Games/BloxFruits/Encrypted`.
- Mantido o carregamento público por `DragonHUB.lua`.
