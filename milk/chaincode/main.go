package main

import (
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/xiebei1108/hyperledger-fabric-samples/milk/chaincode/milkcontract"
)

func main() {
	contract := new(milkcontract.MilkContract)
	contract.Name = "org.example.milk"
	contract.Info.Version = "0.0.1"

	contractChaincode, err := contractapi.NewChaincode(contract)

	if err != nil {
		panic(fmt.Sprintf("Error creating contractChaincode. %s", err.Error()))
	}

	contractChaincode.Info.Title = "MilkChaincode"
	contractChaincode.Info.Version = "0.0.1"

	err = contractChaincode.Start()

	if err != nil {
		panic(fmt.Sprintf("Error starting contractChaincode. %s", err.Error()))
	}
}