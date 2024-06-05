# Jogao

Trabalhando no momento: 
	[ ] - Fazer cada jogador controlar a sua arma
	[ ] - Conectar os sinais da arma com a HUD
	[ ] - Criar um sistema melhor para setar posição de spawn de jogadores
	
Algumas coisas como o player de música no menu principal e os cursores estão definidos apenas para deixar pronto para a troca por assets reais, e não são o resultado final esperado.

Tentei seguir um vídeo que dizia pra usar Componentes ao invés de Herança, mas acabei caindo na herança aos poucos e foi o que deu certo.

Não defini nenhuma "norma" de código, mas tenho tentado por enquanto o seguinte (mas não segui 100%, gostaria de padronizar depois):
	- Usar a opção "Access as Unique Name" para Nodos com caminho grande
	- Constantes COM_NOME_ASSIM
	- Variáveis que se referem a classes ou nodos (mas não as suas instâncias) ComNomeAssim
	- Demais variáveis com_nome_assim, (é o padrão do Godot, mas não sei se justamente por isso deveria fazer diferente, para que as variáveis nativas sejam distinguíveis das variáveis criadas, ex: player.position e player.playerName)
	- Duas linhas em branco entre funções
	- Tudo tipado, usando a tipagem ímplicita := quando possível
	- Sinais antes das variáveis
	- Aspas duplas para strings
	- As variáveis estão agrupadas por @onready @export e normal, mas não tenho certeza se é uma boa
	
provavelmente tem outras coisas que eu não pensei ainda
além da organizaçã das pastas, que eu acho que tá ok, mas as vezes eu me perco um pouco
