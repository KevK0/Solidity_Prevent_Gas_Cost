# Solidity_Prevent_Gas_Cost

This Repository is a proof of concept which shows that it is possible to prevent gas cost for various actions on the blockchain by using Whisper/Swarm and message signing (currently only natively supported by MetaMask).

## How it works

The provided code covers the example of a fully decentralized freelancing platform where a client signs a job creation command and a freelancer signs a bid creation command which are distributed via Whisper. If the client decides to select a freelancer he simple needs to invoke the execute command using (can be abstracted away from the user) his signed initial job creation command and the signed chosen bid. In this case he only needs to pay gas when chosing a freelancer. If he decides to not credit the job to anyone nobody has to pay gas and the blockchain don't has to deal with the (useless) transactions.

## signing messages

### Job

In order to publish a job via whisper one needs to sign a command such as the one seen below.
```
bzz://0x0;1514526663;Freelance
```
The parameter are seperated by ';' to allow ',' in the messages if needed.
The first parameter is the swarm link to the data and the second is the timestamp when the message was created. We need the timestamp to invalidate the whole signed message after some time. (In our example 7 days)

When the message was signed successfully we receive a string like this.
```
0xd57778066a345155a225aba7e8b97af1137728beac399d121258711f4479634e7542e165209c858d83cd6755c718a9f948513cae9e13a53706491280c386847a1c
```

We are later able to idetify the signer via a ecrecover function call in the smart contract.
```
0x0A723351E6637A1A519d0778acCA42FA6aF0b091
```

### Bid

In order to publish a bid via whisper one needs to sign a command such as the one seen below.
```
0x627a7a3a2f2f3078303b313531343532363636333b467265656c616e6365;1514527023;100000000000000000;Bid
```
The first parameter is the previously generated signed message of the job (to identify the job) the second is the timestamp when the message was created. The third is the proposed price of the freelancer and the fourth is again a identification string.

When the message was signed successfully we receive a string like this.
```
0x4a89a6afb5bc3f5d967075f568ee53d74fe5c22c1dce77abcaab0b95ab662dbf7f35ff8042323eb45e612d44d0d5a28625a315254e89bb9f36cf83ca929e69dc1b
```

We are later able to idetify the signer via a ecrecover function call in the smart contract.
```
0x0A723351E6637A1A519d0778acCA42FA6aF0b091
```

### Verify Job Creation Command

```
"bzz://0x0","1514443160","0xd57778066a345155a225aba7e8b97af1137728beac399d121258711f4479634e7542e165209c858d83cd6755c718a9f948513cae9e13a53706491280c386847a1c","30","1000","Freelance"
```
The varous arguments are:
1) swarm link,
2) timestamp(becomes useless after some time),
3) signed message,
4) length of the initially signed message (always 30),
5) additional parameter in this case the price
6) identification string

### Verify Job Bid Command

```
"0xd57778066a345155a225aba7e8b97af1137728beac399d121258711f4479634e7542e165209c858d83cd6755c718a9f948513cae9e13a53706491280c386847a1c","1514447274","0x4a89a6afb5bc3f5d967075f568ee53d74fe5c22c1dce77abcaab0b95ab662dbf7f35ff8042323eb45e612d44d0d5a28625a315254e89bb9f36cf83ca929e69dc1b","166","100000000000000000","Bid"
```
The varous arguments are:
1) signed mjob message,
2) timestamp(becomes useless after some time),
3) signed message,
4) length of the initially signed message (always 166),
5) additional parameter in this case the price
6) identification string

### Preventing double usage

Every timestamp can only be used once per person thus we ensure that nopbody is able to use a message twice.
