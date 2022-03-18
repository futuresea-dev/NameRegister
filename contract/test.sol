//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// 
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract NameRegister {

    using SafeMath for uint256;

    struct UserInfo {
        uint256 registeredBlock;
        uint256 amount;
        uint numBlocks;
        address owner;
    }

    mapping(bytes32 => UserInfo) public userInfo;

    uint256 public nameFee = 100000000000000;

    error NotEnoughEther();
    error AlreadyRegistered();
    error NotOwner();

    constructor(uint256 _nameFee) {
        nameFee = _nameFee;
    }

    function register(bytes32 _name, uint _numBlocks) external payable {

        if (nameFee.mul(_numBlocks) > msg.value) revert NotEnoughEther();

        UserInfo storage user = userInfo[_name];

        if (block.number - user.registeredBlock >= user.numBlocks) {

            uint256 amount = msg.value;

            if (amount > nameFee.mul(_numBlocks))
                amount = nameFee.mul(_numBlocks);   
            else
                payable(msg.sender).transfer(msg.value - amount);

            user.registeredBlock = block.number;
            user.amount = amount;
            user.numBlocks = _numBlocks;
            user.owner = msg.sender;
        } else {
            revert AlreadyRegistered();
        }
    }

    function renew(bytes32 _name, uint _numBlocks) external payable {

        if (nameFee.mul(_numBlocks) > msg.value) revert NotEnoughEther();

        UserInfo storage user = userInfo[_name];

        if (user.owner != msg.sender) revert NotOwner();

        uint256 amount = msg.value;

        if (amount > nameFee.mul(_numBlocks))
            amount = nameFee.mul(_numBlocks);   
        else
            payable(msg.sender).transfer(msg.value - amount);

        if (block.number - user.registeredBlock >= user.numBlocks) { // renew
            user.registeredBlock = block.number;
            user.amount = amount;
            user.numBlocks = _numBlocks;
            user.owner = msg.sender;
        } else { // extend
            user.numBlocks += _numBlocks;
            user.amount += amount;
        }
    }

    function cancel(bytes32 _name) external {

        UserInfo storage user = userInfo[_name];

        require(user.owner == msg.sender, "Not Owner");

        if (block.number - user.registeredBlock < user.numBlocks) {
            uint256 remain = nameFee.mul(user.registeredBlock + user.numBlocks - block.number);
            user.amount -= remain;
            user.numBlocks = block.number - user.registeredBlock;
            payable(msg.sender).transfer(remain);
        }
    }
}