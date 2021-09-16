// Definindo versao do solidity para criar o contrato
pragma solidity 0.7.0;

// Crando contrato
contract HelloWorld {
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
    function setText(string memory myText) public {
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
        hasCountInteracted[msg.sender] += 1;
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
        return num1 + number;
    }

    // ----------------- Funcoes pagas em ether ----------------
    
    // PAYABLE define que a funcao e paga
    // REQUIRE - condicao para o resto do código ser executado 
    // msg.value - Quantidade enviada para a chamada da funcao
    function setNumberPayable(uint myNumberPay) public payable{
        require(msg.value >= 1 ether , "Insufficient ETH send.");
        balances[msg.sender] += msg.value;
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
}