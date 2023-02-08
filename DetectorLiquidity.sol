pragma solidity ^0.8.0;

contract LiquidityDetector {
    // Dirección del contrato inteligente que se está monitoreando
    address public targetContract;

    // Variables que almacenan la cantidad de tokens en el contrato y la cantidad de ether
    uint256 public tokenBalance;
    uint256 public etherBalance;

    // Evento para notificar cuándo se actualiza la liquidez
    event LogLiquidityUpdated(uint256 _tokenBalance, uint256 _etherBalance);

    // Función para establecer la dirección del contrato inteligente a monitorear
    function setTargetContract(address _targetContract) public {
        targetContract = _targetContract;
    }

    // Función para actualizar la liquidez
    function updateLiquidity() public {
        // Obtiene la cantidad de tokens en el contrato inteligente a monitorear
        tokenBalance = ERC20(targetContract).balanceOf(address(this));

        // Obtiene la cantidad de ether en el contrato inteligente a monitorear
        etherBalance = address(targetContract).balance;

        emit LogLiquidityUpdated(tokenBalance, etherBalance);
    }

    // Función para obtener la liquidez actual
    function getLiquidity() public view returns (uint256, uint256) {
        return (tokenBalance, etherBalance);
    }
}