package milkcontract

import "github.com/hyperledger/fabric-contract-api-go/contractapi"

type MilkContract struct {
	*contractapi.Contract
}

func (mc *MilkContract) PutState(ctx contractapi.TransactionContextInterface, key, value string) error {
	return ctx.GetStub().PutState(key, []byte(value))
}

func (mc *MilkContract) GetState(ctx contractapi.TransactionContextInterface, key string) (string, error) {
	value, err := ctx.GetStub().GetState(key)
	if err != nil {
		return "", err
	}
	return string(value), nil
}