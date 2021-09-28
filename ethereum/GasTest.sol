pragma solidity 0.7.0;

/****

Você pode aprender mais no Yellow Paper do Ethereum, no apêndice G:
https://ethereum.github.io/yellowpaper/paper.pdf
* se você for louco, pode ler o apêndice H também.

Mas aqui tem uma tabela que resume de forma bem clara (recomendado):
https://docs.google.com/spreadsheets/d/1n6mRqkBz3iWcOlRem_mO09GtSKEKrAsfO7Frgx18pNU/edit#gid=0

E aqui tem um artigo detalhando como o custo é calculado em alguns exemplos:
https://vomtom.at/what-exactly-is-the-gas-limit-and-the-gas-price-in-ethereum/

Pontos mais importantes:
1) Cada operação custa GAS. Quanto mais complexo for o seu código, mais caro será para executá-lo.
2) Cada transação tem um custo básico de 21000 Gas. Soma-se a isso todas as operações que a transação envolve ("custo de execução"), mais o custo dos parâmetros.
3) A operação mais cara é salvar valores na blockchain (SSTORE). A segunda mais cara é consultar valores da blockchain (SLOAD).
4) Setar um valor para ZERO é muito barato, pois libera memória. Além disso, desocupar memória que não está sendo usada é boa prática de cidadania.
5) Setar um valor para ele mesmo é mais barato do que alterar o valor.
6) A Solidity demanda um tipo de programação diferente das demais linguagens. Você sempre deve buscar um equilíbrio entre ter um código estruturado e ter um código econômico.
7) Strings não têm um tamanho definido, por isso geram warnings de "gás possivelmente infinito". O mesmo acontecerá para loops dinâmicos e arrays de tamanho dinâmico.
8) Funções PURE e VIEW são grátis para usuários, mas custam Gas quando são chamadas por CONTRATOS. Por isso as funções da SafeMath não são grátis, mesmo sendo puras.
9) Para descobrir o custo total em Gas de uma função, execute-a na Remix e consulte o campo "transaction cost".

****/

contract GasTest {
	bool public bool_;
	uint public uint_;
	int public int_;
	address public address_;
	string public string_;
	mapping(address => uint) public mapping_;
	
	address public owner;

	event AnEvent();

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	
	constructor () public {
	    owner = msg.sender;
	}

	/*##########################*/
	/* MATEMÁTICA */

	//~ Conta simples ~
	//@GAS: 22107
	function add(uint a, uint b) public pure returns(uint) {
		return a + b;
	}

	//~ SafeMath ~
	//@GAS: 22129
	function safeAdd(uint a, uint b) public pure returns(uint) {
		uint c = a + b;
		require(c >= a, "Sum Overflow!");

		return c;
	}


	/*##########################*/
	/* CONDIÇÕES */

	//~ IF ~
    //@GAS: 22294
	function addConditionally(uint a, uint b) public view returns(uint) {
		if(msg.sender != owner) {
			revert();
		}

		return a + b;
	}

	//~ REQUIRE ~
	//@GAS: 22318
	function addWithRequire(uint a, uint b) public view returns(uint) {
		require(msg.sender == owner);

		return a + b;
	}

	//~ MODIFIER ~
	//@GAS: 22340
	function addWithModifier(uint a, uint b) onlyOwner public view returns(uint) {
		return a + b;
	}


	/*##########################*/
	/* TIPOS DE VARIÁVEIS */

	//~ BOOL ~
	//@GAS from FALSE to TRUE:  42082
	//@GAS from TRUE to FALSE:  13509 (zerar um campo é MUITO mais barato)
	//@GAS from FALSE to FALSE: 22218
	//@GAS from TRUE to TRUE:   22282
	function setBool(bool myBool) public {
		bool_ = myBool;
	}

	//~ UINT ~
	//@GAS from ZERO to NOT-ZERO:     41734
	//@GAS from NOT-ZERO to NOT-ZERO: 26734
	//@GAS from NOT-ZERO to ZERO:     13335 (zerar um campo é MUITO mais barato)
	function setUint(uint myUint) public {
		uint_ = myUint;
	}

	//~ INT ~
	//@GAS from ZERO to NOT-ZERO:     41778 
	//@GAS from NOT-ZERO to NOT-ZERO: 26778
	//@GAS from NOT-ZERO to ZERO:     13357 (zerar um campo é MUITO mais barato)
	function setInt(int myInt) public {
		int_ = myInt;
	}

	//~ ADDRESS ~
	//@GAS from ZERO to NOT-ZERO:     43210 
	//@GAS from NOT-ZERO to NOT-ZERO: 28210
	//@GAS from NOT-ZERO to ZERO:     13465 (zerar um campo é MUITO mais barato)
	function setAddress(address myAddress) public {
		address_ = myAddress;
	}

	//~ STRING ~
	//@GAS from "" to "a":  42982 
	//@GAS from "a" to "b": 28239
	//@GAS from "b" to "":  13989 (zerar um campo é MUITO mais barato)
	//@GAS from "" to "abcdefghijklmnopqrstuvxz": 44454 (o tamanho da string faz diferença)
	//@GAS from "abcdefghijklmnopqrstuvxz" to "abcdefghijklmnopqrstuvxzBLABLABLA": 70337 (cada caractere aumenta o custo; pico de custo a cada limite de tamanho 32/64/128/256)
	//@GAS from "abcdefghijklmnopqrstuvxzBLABLABLA" to "a": 19048 (zerou um bocado da memória, então ficou bem mais barato)
	//@GAS from "abcdefghijklmnopqrstuvxzBLABLABLA" to "":  18917 (zerou toda a memória separada para aquela string, então ficou ainda mais barato)
	function setString(string memory myString) public {
		string_ = myString;
	}

	//~ MAPPING ~
	//@GAS from ZERO to NOT-ZERO:     41844 
	//@GAS from NOT-ZERO to NOT-ZERO: 26844
	//@GAS from NOT-ZERO to ZERO:     13390 (zerar um campo é MUITO mais barato)
	function setMapping(uint myUint) public {
		mapping_[msg.sender] = myUint;
	}

	//~ Nome de função com mais de 32 caracteres ~
	//@GAS from ZERO to NOT-ZERO:     41866 
	//@GAS from NOT-ZERO to NOT-ZERO: 26866
	//@GAS from NOT-ZERO to ZERO:     13401 (zerar um campo é MUITO mais barato)
	function setMappingWithAVeryLongNameIndeed(uint myUint) public {
		mapping_[msg.sender] = myUint;
	}

	//~ Eventos ~
	//@GAS from ZERO to NOT-ZERO:     42667 
	//@GAS from NOT-ZERO to NOT-ZERO: 27667
	//@GAS from NOT-ZERO to ZERO:     13802 (zerar um campo é MUITO mais barato)
	function setMappingAndFireEvent(uint myUint) public {
		mapping_[msg.sender] = myUint;

		emit AnEvent();
	}

	//~ Parâmetros ~
	//@GAS from ZERO to NOT-ZERO:     43268 
	//@GAS from NOT-ZERO to NOT-ZERO: 28268
	//@GAS from NOT-ZERO to ZERO:     14102 (zerar um campo é MUITO mais barato)
	function setMappingPassingAddress(address to, uint myUint) public {
		mapping_[to] = myUint;
	}
}

/******

EPÍLOGO: PARA ONDE IR AGORA?

Leia a documentação:
https://solidity.readthedocs.io/

Visite o Stack Exchange para aprender com os problemas dos outros.
https://ethereum.stackexchange.com/

Leia contratos que já estão na blockchain e têm código verificado.
https://etherscan.io/

Leia implementações do OpenZeppelin e aprenda variações de contratos.
https://github.com/OpenZeppelin/openzeppelin-solidity/tree/master/contracts

Pesquise sobre STRUCTS! :)

******/