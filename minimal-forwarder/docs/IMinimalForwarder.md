# IMinimalForwarder









## Methods

### execute

```solidity
function execute(IMinimalForwarder.ForwardRequest req_, bytes signature_) external payable returns (bool, bytes)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| req_ | IMinimalForwarder.ForwardRequest | undefined |
| signature_ | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |
| _1 | bytes | undefined |

### getNonce

```solidity
function getNonce(address from_) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| from_ | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### verify

```solidity
function verify(IMinimalForwarder.ForwardRequest req_, bytes signature_) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| req_ | IMinimalForwarder.ForwardRequest | undefined |
| signature_ | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |




