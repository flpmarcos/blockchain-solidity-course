// Definindo versao do solidity para criar o contrato
pragma solidity 0.7.0;

// Desafio
// Modulo Facil
/*
    Receber um numero de 0a 10, que sera passado por um usuario.
    Se o numero recebido for maior que 5, retornar o texto "É mario que cinco!"
    Se o numero recebido for menor ou igual a 5, retornar o texto "É menor ou igual a cinto"
    Cobrar exatamente 2 eth para executar a funcao
*/
// Modulo Intermediario
/*
    O preço para executar a funcao duplica cada vez que ela é executada.
    Sempre que o preço muda, o contrato dispara um evento informando qual é o novo preço.
 */
// Modulo Dificil
/*
    O dono do contrto é dono de todo ETH no contrto e pode saca-lo.
    O dono do contrto pode escolher o valor a ser sacado em cada saque.
 */

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

contract ProblemSection is Ownable {   
    // Instanciando biblioteca criada acima, fazendo com que operacoes uint possam fazer operacoes de forma segura
    using SafeMath for uint; 
    
    uint ethValue = 2 ether;
    
    event NewPayValue(uint ethValue);
    
    
    function recieveNumber(uint a) public payable returns(string memory){
        require(a <= 10 , "Number is not valid");
        
        require(msg.value >= ethValue, "Insufficient ETH send.");
        
        doublePrice();
        emit NewPayValue(ethValue);
          
        if(a > 5) {
            return "E maior que cinco!";
        }
        
        return "E menor ou igual a cinco";
    }

    function doublePrice() private {
        ethValue = ethValue.mulSafe(2);
    }

    // BALANCE é uma propriedade nativa de todo endereco

    // Saque de moedas
    function withdraw(uint myAmount)  onlyOwner public {
        // Como o exercicio envolve todo o dinheiro do contrato essa funcao default trabalha somente
        // Com valor do contrato
        // A outra foram de withdraw serve para diferenciar os valores
        require(address(this).balance >= myAmount, "Insufficient funds.");

        owner.transfer(myAmount);
    }


}

