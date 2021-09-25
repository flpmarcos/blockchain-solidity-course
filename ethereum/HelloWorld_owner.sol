// Definindo versao do solidity para criar o contrato
pragma solidity 0.7.0;

// Criando uma biblioteca de codigos, e ainda por cima evitando overflow e underflow
library SafeMath {
    // ----------------- REPLICANDO A LIB SAFEMATH PARA ENTENDER O FUNCIONAMENTO DA MESMA ----------------
    // Essas funcoes agora sao internal e o usuario nao pode ve-las
    function sumSafe(uint a,uint b) internal pure returns(uint){
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

// Crando contrato
// is Ownable define que o Contract helloworld herda as propridades do contrato que chama Ownable 
contract HelloWorld is Ownable {
    // Instanciando biblioteca criada acima, fazendo com que operacoes uint possam fazer operacoes de forma segura
    using SafeMath for uint; 

    // Variavel que vai armazenar o numero da carteria que vai deployar o contrato
   
    
    // defindino string text como publica -> acessivel na blockchain
    string public text;
    uint public number;
    address public userAddress;
    bool public answer;
    mapping (address => bool) public hasInteracted;
    mapping (address => uint) public hasCountInteracted;
    uint public numberPay;
    mapping (address => uint) public balances;

  
    // Criando a funcao setText que recebe a variavel myText
    // memory quer dizer que a funcao vai persistir somente quando chamada
    // public define a funcao como publica
    function setText(string memory myText) onlyOwner public {
        text = myText;
        setInteracted();
        setCountInteracted();
    }

    // Recebe o um valor inteiro e armazena em variavel
    function setNumber(uint myNumber) public {
        number = myNumber;
        setInteracted();
        setCountInteracted();
    }



    // Obtem o endereco da carteira de quem executa o contrato
    function setAddress () public {
        userAddress = msg.sender;
        setInteracted();
        setCountInteracted();
    }

    // Recebe um valor boleano e retorna na variavel
    function setAnswer(bool trueOrFalse) public {
        answer = trueOrFalse;
        setInteracted();
        setCountInteracted();
    }

    // Funcao privada que é chamda em todos os metodos publicos para inserir true caso a carteira execute algo no contrato
    function setInteracted() private {
        hasInteracted[msg.sender] = true;
    }

    // Funcao que conta quantas vezes a carteira interagiu com o contrato
    function setCountInteracted() private {
        hasCountInteracted[msg.sender] = hasCountInteracted[msg.sender].sumSafe(1);
    }

    // ------------- Funcoes de calculo -------------------

    // Quando a funcao na manipula nenhuma variavel a não ser a dela mesma que recebe como parametro
    // As funcoes do de PURE não alteram e nem consultam algo na blockchain
    function sum (uint num1 , uint num2) public pure returns(uint) {
        return num1 + num2;
    }
    // Funcao de substracao
    function sub (uint num1 , uint num2) public pure returns(uint) {
        return num1 - num2;
    }
    // Funcao de multiplicacao
    function mult (uint num1 , uint num2) public pure returns(uint) {
        return num1 * num2;
    }
    // Funcao de divisao
    function div (uint num1 , uint num2) public pure returns(uint) {
        return num1 / num2;
    }
    // Funcao de potencia
    function pow (uint num1 , uint num2) public pure returns(uint) {
        return num1 ** num2;
    }

    // As funcoes do tipo view só consultam mais nao alteram
    function sumStores(uint num1) public view returns(uint) {
        // Quando voce chama uma funcao o parametro a e o que vem antes do . e o parametro b é o que vem entre parenteses
        return num1.sumSafe(number);
    }

    // ----------------- Funcoes pagas em ether ----------------
    
    // PAYABLE define que a funcao e paga
    // REQUIRE - condicao para o resto do código ser executado 
    // msg.value - Quantidade enviada para a chamada da funcao
    function setNumberPayable(uint myNumberPay) public payable{
        require(msg.value >= 1 ether , "Insufficient ETH send.");
        balances[msg.sender] = balances[msg.sender].sumSafe(msg.value);
        numberPay = myNumberPay;
        setInteracted();
        setCountInteracted();
    }

    // a funcao transfer é default da rede etherium ele que é para transferir etherium
    function sendEth(address payable targetAddress) public payable {
        targetAddress.transfer(msg.value);

    }

    // Saque de moedas
    function withdraw() public {
        // Valida se o usuario tem saldo na conta
        require(balances[msg.sender] > 0 , "Insufficient funds");
        // Envia o valor do saldo do usuario para uma variavel - resolvendo o erro da reentrancia
        uint amount = balances[msg.sender];
        // Esvazia a conta do usuario
        balances[msg.sender] = 0;
        // E tranfere a quantia
        msg.sender.transfer(amount);

    }

    // ----------------- OVERFLOW E UNDERFLOW ----------------
    // As variaveis tem limites e não podemos estoura-la, abaixo o tamanho das variaveis uint
    /*
    uint8 : 0 a 255
    uint16: 0 a 65.535
    uint32: 0 a 4.297.967.294
    uint64: 0 a 18.446.744.073.709.551.615
    uint128: 0 a 340.282.366.920.938.463.463.374.607.431.768.211.455
    uint256: 0 a 112.792.....................

    Exite também o tipo de variavel int. Ele alcança METADE desde valores, porque podem ser negativos.
    int8 : -128 a 127
    int16: -32768 a 32767
    int32: -2.147.483.648 a 2.147.483.647
    E assim por diante
    */
    
    
}