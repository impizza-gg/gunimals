# Jogao
	
Algumas coisas como o player de música no menu principal e os cursores estão definidos apenas para deixar pronto para a troca por assets reais, e não são o resultado final esperado.

#### Padrões de código:

- Usar a opção "Access as Unique Name" para Nodos com caminho grande
- Constantes COM_NOME_ASSIM
- Variáveis que se referem a classes ou nodos (mas não as suas instâncias) ComNomeAssim
- Demais variáveis com_nome_assim, (é o padrão do Godot, mas não sei se justamente por isso deveria fazer diferente, para que as variáveis nativas sejam distinguíveis das variáveis criadas, ex: player.global_position e player.playerName)
- Duas linhas em branco entre funções
- Tudo tipado, usando a tipagem ímplicita := quando possível
- Sinais antes das variáveis
- Aspas duplas para strings
- As variáveis estão agrupadas por @onready @export e normal, mas não tenho certeza se não seria melhor agrupar por funcionalidade

#### Organização de pastas:
