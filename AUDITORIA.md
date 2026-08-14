# Auditoria do DragonHUB

Atualização: 14/08/2026

## Resultado estrutural

- 9 arquivos Lua executáveis no repositório.
- 0 arquivos Python.
- 0 arquivos nas antigas árvores artificiais `Source/Functions` e `Source/Modules`.
- 0 referências executáveis para `Encrypted`, `DragonFunctionLinks` ou carregadores de módulos genéricos.
- 187 toggles, 16 seletores, 2 sliders, 1 campo de texto e 92 botões identificados no runtime.
- 205 callbacks `OnChanged` permanecem registrados.

## Problema encontrado

A versão anterior não estava criptografada, mas simulava uma estrutura modular. Os arquivos individuais tinham entre 3 e 11 linhas e apenas recebiam um callback cuja implementação continuava dentro de `Runtime.lua`. Os scripts Python apenas recriavam esses wrappers e os manifestos derivados.

Essa camada aumentava o número de arquivos e requisições HTTP sem separar a lógica real.

## Correção aplicada

- Removidos 198 wrappers Lua sem implementação própria.
- Removidos os manifestos e carregadores usados exclusivamente pelos wrappers.
- Removidos `generate_functions.py` e `generate_hub_layout.py`.
- Simplificados os modos HUB e AUTOMÁTICO para carregar somente os arquivos necessários.
- Alterado o despacho da interface para executar diretamente os callbacks registrados pelo runtime.
- Reorganizados os trechos comprimidos de `Runtime.lua` e `HubUI.lua` somente com mudanças de espaço e quebra de linha.
- Atualizada a documentação para representar a arquitetura real.

## Validação

- `Runtime.lua` agora compila integralmente sem ultrapassar o limite de 200 variáveis locais.
- Os 9 arquivos Lua passaram na análise sintática após a correção do modo HUB.
- A sequência de 88.443 tokens do `Runtime.lua` permaneceu idêntica depois da reorganização visual, considerando a remoção intencional dos carregadores artificiais.
- A sequência de 4.601 tokens do `HubUI.lua` também permaneceu idêntica depois da reorganização visual, considerando a simplificação intencional do despacho.
- Todas as referências aos arquivos removidos foram eliminadas.
- O manifesto aponta apenas para arquivos Lua existentes.

As referências dos controles da interface não usam o escopo `local` principal. Isso evita o limite do compilador sem alterar os callbacks conectados a cada controle.
