// Definindo versao do solidity para criar o contrato
pragma solidity 0.7.0;

// Crando contrato
contract HelloWorld {
    // defindino string text como publica -> acessivel na blockchain
    string public text;

    // Criando a funcao setText que recebe a variavel myText
    // memory quer dizer que a funcao vai persistir somente quando chamada
    // public define a funcao como publica
    function setText(string memory myText) public {
        text = myText;
    }


}