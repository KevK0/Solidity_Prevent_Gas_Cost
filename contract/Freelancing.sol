pragma solidity ^0.4.14;

import "string_cast.sol";


contract Freelancing{
    using stringcast for string;
    
    address master;
    
    struct job{
        address client;
        address freelancer;
    }
    
    job[] jobs;
    
    mapping(address => mapping(uint => bool) ) used_datetime;
    
    function Freelancing() public{
        master = msg.sender;
    }
    
    function recover(string message,string valid_until, string sigs,string lenStr, string price, string what) pure public returns (address) {
        bytes memory sig = sigs.toBytes();
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
            
        bytes32 r;
        bytes32 s;
        uint8 v;
    
        //Check the signature length
        if (sig.length != 65) {
          return (address(0));
        }
    
        // Divide the signature in r, s and v variables
        assembly {
          r := mload(add(sig, 32))
          s := mload(add(sig, 64))
          v := byte(0, mload(add(sig, 96)))
        }
    
        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
          v += 27;
        }
    
        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
          return (address(0));
        } else {
            if(keccak256(what) == keccak256("Freelance")){
                bytes32 hash = keccak256(prefix, lenStr, message, ';', valid_until, ";", what);
                return ecrecover(hash, v, r, s);
            }
            else{
                bytes32 hash2 = keccak256(prefix, lenStr, message, ';', valid_until, ";", price, ";", what); 
                return ecrecover(hash2, v, r, s);
            }
        }
    }
    
    function setDatetimeUsed(string valid_until) private{
        uint256 valid_until_u = valid_until.toUint() + (7 * 1 days);
        require(used_datetime[msg.sender][valid_until_u] == false);
        require(valid_until_u > block.timestamp);
        used_datetime[msg.sender][valid_until_u] = true;
    }
    
    function execute(string link, string valid_until, string proof, address freelancer, string bid_valid_until, string bid_proof, string price) external{
        require(msg.sender == recover(link,valid_until,proof,"30","-","Freelance"));
        
        address free1 = recover(proof,bid_valid_until,bid_proof,"166", price, "Bid");
        
        setDatetimeUsed(valid_until);
        
        job memory j;
        j.client = msg.sender;
        j.freelancer = free1;
        
        jobs.push(j);
    }
    
}
