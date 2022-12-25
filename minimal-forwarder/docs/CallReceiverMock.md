# CallReceiverMock









## Methods

### mockFunction

```solidity
function mockFunction() external payable returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### mockFunctionNonPayable

```solidity
function mockFunctionNonPayable() external nonpayable returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### mockFunctionOutOfGas

```solidity
function mockFunctionOutOfGas() external payable
```






### mockFunctionRevertsNoReason

```solidity
function mockFunctionRevertsNoReason() external payable
```






### mockFunctionRevertsReason

```solidity
function mockFunctionRevertsReason() external payable
```






### mockFunctionThrows

```solidity
function mockFunctionThrows() external payable
```






### mockFunctionWithArgs

```solidity
function mockFunctionWithArgs(uint256 a, uint256 b) external payable returns (string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| a | uint256 | undefined |
| b | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### mockFunctionWritesStorage

```solidity
function mockFunctionWritesStorage() external nonpayable returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### mockStaticFunction

```solidity
function mockStaticFunction() external pure returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### sharedAnswer

```solidity
function sharedAnswer() external view returns (string)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |



## Events

### MockFunctionCalled

```solidity
event MockFunctionCalled()
```






### MockFunctionCalledWithArgs

```solidity
event MockFunctionCalledWithArgs(uint256 a, uint256 b)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| a  | uint256 | undefined |
| b  | uint256 | undefined |



