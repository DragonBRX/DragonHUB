# Auditoria DragonHUB

Atualização: 14/08/2026

- 297 controles encontrados no HUB, incluindo o campo `JobID`.
- 187 toggles com módulo individual aberto e legível.
- 205 callbacks de toggle, dropdown e slider registrados pelo runtime.
- 91 ações de botão registradas pelo runtime.
- Nenhum módulo individual ausente no código-fonte.
- `Auto Farm Level` permanece disponível nos três Seas e seleciona a missão pelo mundo e nível atuais.
- Funções de fruta, incluindo `Auto Random Fruit`, `Random Fruit Now` e o sniper de estoque, permanecem disponíveis nos três Seas.
- Funções exclusivas agora são filtradas por Sea no próprio layout do HUB.
- O acesso obrigatório a `_WorldOrigin["Foam;"]` foi substituído por detecção opcional para não interromper o runtime.
- O `HumanoidRootPart` é atualizado após respawn para evitar referências antigas.
- Erros individuais de carregamento ou execução agora aparecem na barra de status da interface.
- A janela antiga e o botão com imagem externa foram desativados no modo HUB.
- O runtime registra as funções por um adaptador sem interface; somente `HubUI.lua` cria a janela visível.
- Nomes e menus da interface própria não usam emojis.
- Dropdowns utilizam lista flutuante rolável com seleção única em vez de troca cíclica.
- A consulta de estoque não interrompe mais o carregamento do runtime quando o servidor retorna um resultado vazio ou um erro transitório.
- A compra básica voltou a usar `PurchaseRawFruit(nome, false)`, conforme o bloco funcional do código anterior.
- `Auto Random Fruit` executa o giro imediatamente ao ser ativado e repete a chamada original a cada 0,1 segundo.
- `Random Fruit Now` oferece o giro direto de uma tentativa, independentemente do estado do toggle automático.

Validação realizada:

- Os 203 arquivos Lua executados estão disponíveis diretamente em `Games/BloxFruits/Source`.
- Manifesto, registro de funções, layout, modos e módulos apontam somente para arquivos-fonte legíveis.
- A pasta `Encrypted` e o gerador de wrappers criptografados foram removidos desta versão.
- Correção funcional publicada no commit `36526fa9f2d7a7d52edf93b65cabc1b8af585967`.
- Carregamento ant-cache publicado no commit `c25e14d1a968334011f9040f8af3389cbb9c317f`.
- Interface própria única publicada no commit `5561e3ecdb005e4b90a6c296c6d80d640e358dfb`.
- Seletores flutuantes publicados no commit `54e68e05770dd688fbf3b62437dfe78fd76db781`.
- Giro imediato de fruta publicado no commit `c8dd066f9e855f19d41e012de5cde6aa53ba130d`.
