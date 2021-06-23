// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./PriceConsumerV3.sol";
import "./lib/PerpetualTypes.sol";
import "hardhat/console.sol";

/// @title A perpetual contract w/ aTokens as collateral
/// @author Markus Schick
/// @notice You can only buy one type of perpetual and only use USDC as reserve

contract Reserve {
    using SafeERC20 for IERC20;
    /************************* state *************************/

    PerpetualTypes.CollateralType collateralType;

    // reserve assets
    IERC20 public USDC;
    IERC20 public aUSDC;
    IERC20 public aETH;

    struct Position {
        uint256 USDCBalance;
        uint256 aUSDCBalance;
        uint256 aETHBalance;
        uint256 longBalance;
        uint256 shortBalance;
    }

    mapping(address => Position) balances;

    /************************* events *************************/

    event Deposit(uint256, address indexed, PerpetualTypes.CollateralType);
    event Withdraw(uint256, address indexed, PerpetualTypes.CollateralType);

    /************************* external *************************/

    /* deposit */
    function depositUSDC(uint256 _amount) public {
        USDC.safeTransferFrom(msg.sender, address(this), _amount);
        balances[msg.sender].USDCBalance += _amount;
        emit Deposit(_amount, msg.sender, PerpetualTypes.CollateralType.USDC);
    }

    function depositaUSDC(uint256 _amount) public {
        aUSDC.safeTransferFrom(msg.sender, address(this), _amount);
        balances[msg.sender].USDCBalance += _amount;
        emit Deposit(_amount, msg.sender, PerpetualTypes.CollateralType.aUSDC);
    }

    function depositaETH(uint256 _amount) public {
        aETH.safeTransferFrom(msg.sender, address(this), _amount);
        balances[msg.sender].aETHBalance += _amount;
        emit Deposit(_amount, msg.sender, PerpetualTypes.CollateralType.aUSDC);
    }

    /* withdraw */
    function withdrawUSDC(uint256 _amount) public {
        require(
            _amount <= balances[msg.sender].USDCBalance,
            "Can not require more than in balance"
        );
        balances[msg.sender].USDCBalance -= _amount;
        USDC.safeTransfer(msg.sender, _amount);
        emit Withdraw(_amount, msg.sender, PerpetualTypes.CollateralType.USDC);
    }

    function withdrawaUSDC(uint256 _amount) public {
        require(
            _amount <= balances[msg.sender].aUSDCBalance,
            "Can not require more than in balance"
        );
        balances[msg.sender].aUSDCBalance -= _amount;
        aUSDC.safeTransfer(msg.sender, _amount);
        emit Withdraw(_amount, msg.sender, PerpetualTypes.CollateralType.aUSDC);
    }

    function withdrawaETH(uint256 _amount) public {
        require(
            _amount <= balances[msg.sender].aETHBalance,
            "Can not require more than in balance"
        );
        balances[msg.sender].aETHBalance -= _amount;
        aETH.safeTransfer(msg.sender, _amount);
        emit Withdraw(_amount, msg.sender, PerpetualTypes.CollateralType.aETH);
    }

    /************************* view functions *************************/

    function getUSDBalance(address _address) public view returns (uint256) {
        return balances[_address].USDCBalance;
    }

    function getaUSDBalance(address _address) public view returns (uint256) {
        return balances[_address].aUSDCBalance;
    }

    function getaETHBalance(address _address) public view returns (uint256) {
        return balances[_address].aETHBalance;
    }

    /************************* helper functions *************************/

    /// @notice Returns reserve value of a given trader
    /// @dev Ignore ETH value for now
    function getPortfolioValue(address _address) public view returns (uint256) {
        return balances[_address].USDCBalance + balances[_address].aUSDCBalance;
    }
}