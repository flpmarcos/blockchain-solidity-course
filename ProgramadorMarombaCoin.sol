// Definindo versao do solidity para criar o contrato
pragma solidity 0.7.0;

// Criando uma biblioteca de codigos, e ainda por cima evitando overflow e underflow
library SafeMath {
    // ----------------- REPLICANDO A LIB SAFEMATH PARA ENTENDER O FUNCIONAMENTO DA MESMA ----------------
    // Essas funcoes agora sao internal e o usuario nao pode ve-las
    function addSafe(uint a,uint b) internal pure returns(uint){
        uint c = a + b;
        require(c >= a , "Sum Overflow!");

        return c;
    }

    function subSafe(uint a,uint b) internal pure returns(uint){
        require(b <= a , "Sub Overflow!");
        uint c = a - b;
        
        return c;
    }

    function mulSafe(uint a,uint b) internal pure returns(uint){
        // Impede multiplicacao por 0
        if(a == 0){
            return 0;
        }

        uint c = a * b;
        require(c / a == b , "Mult Overflow!");
        
        return c;
    }
    // Funcao de divisao nao tem como dar overflow 
    function divSafe(uint a,uint b) internal pure returns(uint){
        uint c = a / b;
        
        return c;
    }
}



contract Ownable {
    
    // Ao declarar uma variavel owner é necessario definir ela como payable
    address payable public owner;
    
    // Criando um evento que seja chamado quando uma funcao for executada
    event OwnershipTransferred(address newOwner);

    // Funcao default que define a carteira que fez o deploy do contrato como owner
    // Essa funcao roda uma unica vez na vida junto com o contrato
    constructor() public {
        owner = msg.sender;
    }

    // Funcao modifier pode ser incluida na chamada de outras funcoes
    // Nesse caso ela vai validar se o executor da funcao é o dono dela ou nao
    modifier onlyOwner(){
        require(msg.sender == owner, "you are not the owner!");
        // Caso o modifier seja verdadeira essa linha executa o resto da funcao
        _;
    }

    // Criando funcao para tansferir a posse do contrato, somente o dono pode chamar essa funcao
    function transferOwnership(address payable newOwner) onlyOwner public {
        // Inserindo na variavel o novo owner
        owner = newOwner;

        // Emitindo evento da transferencia de conta
        emit OwnershipTransferred(owner);
    }



}

contract ProgramadorMarombaToken is Ownable {
    using SafeMath for uint;

    // Criando inicializacao da moeda 
    /*
        - Nome
        - Simbolo
        - Casas decimais
        - Suply
        - Endereços que tem variavel na carteira
     */
    string public constant name = "Programador Maromba Coin";
    string public constant symbol = "PMC";
    uint8 public constant decimals = 18;
    uint public totalSupply;
    mapping(address => uint) balances;

    // Criando eventos de criacao e trasferencia de token
    // O indexed serve como chave primaria caso algum mecanismo web queira filtrar o evento
    event Mint(address indexed to,uint token);
    event Transfer(address indexed from,address indexed to,uint token);

    // Funcao que criados de token que adicionar na carteira destino e no totalsupply
    function mint(address to,uint tokens) onlyOwner public {
        // Adiciona token na carteira destino
        balances[to] = balances[to].addSafe(tokens);
        // Adiciona token no total supply
        totalSupply - totalSupply.addSafe(tokens);

        // Emitingo o evento de criacao de moedas
        // to é para quem esta sendo enviado e token é a quantidade de moeda
        emit Mint(to,tokens);
    }   

    function transfer(address to,uint tokens) public {
        // Valida se quem esta enviando tem o numero de token para enviar;
        require(balances[msg.sender] >= tokens);
        
        // Validacao para que transferencia não seja realizada para carteira de queima
        require(to != address(0));

        // Subtrai o numero de token da carteira de quem envia
        balances[msg.sender] = balances[msg.sender].subSafe(tokens);
        // Adicionar o token para carteira de quem recebe
        balances[to] = balances[to].addSafe(tokens);

        // Emitindo evento de transferencia de token
        // msg.sender quem transferiu
        // to quem recebe
        // Quantidade
        emit Transfer(msg.sender,to,tokens);
    }

}