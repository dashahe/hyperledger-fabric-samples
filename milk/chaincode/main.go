package main

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	pb "github.com/hyperledger/fabric-protos-go/peer"
)

type MilkManager struct {
}

func (cc *MilkManager) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success([]byte{})
}

func (cc *MilkManager) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	funcName, _ := stub.GetFunctionAndParameters()
	if function, ok := functions[funcName]; ok {
		fmt.Printf("Invoking %s\n", funcName)
		return function(stub)
	}
	return shim.Error(fmt.Sprintf("Unknown function %s", funcName))
}

var functions = map[string]func(stubInterface shim.ChaincodeStubInterface) pb.Response{
	"putState":   putState,
	"getState":   getState,
	"getHistory": getHistory,
}

func getHistory(stub shim.ChaincodeStubInterface) pb.Response {
	_, parameters := stub.GetFunctionAndParameters()
	if len(parameters) != 1 {
		return shim.Error("wrong number of arguments, need milk_id")
	}
	milkID := parameters[0]

	keysIter, err := stub.GetHistoryForKey(milkID)
	if err != nil {
		return shim.Error(fmt.Sprintf("GetHistoryForKey failed, err: %+v", err))
	}

	keys := make([]string, 0)
	for keysIter.HasNext() {
		response, err := keysIter.Next()
		if err != nil {
			return shim.Error(fmt.Sprintf("GetHistoryForKey operation failed, err: %+v", err))
		}
		txValue := response.Value
		txTimestamp := response.Timestamp

		tm := time.Unix(txTimestamp.Seconds, 0)
		dateStr := tm.Format("2006-01-02 03:04:05 PM")

		keys = append(keys, string(txValue) + ":" + dateStr)
	}

	jsonKeys, err := json.Marshal(keys)
	if err != nil {
		return shim.Error(fmt.Sprintf("Eror marshaling json: %+v", err))
	}
	return shim.Success(jsonKeys)
}

func getState(stub shim.ChaincodeStubInterface) pb.Response {
	_, parameters := stub.GetFunctionAndParameters()
	if len(parameters) != 1 {
		return shim.Error("Wrong number of arguments supplied. Expected: milk_id")
	}

	res, err := stub.GetState(parameters[0])
	if err != nil {
		return shim.Error("")
	}
	return shim.Success(res)
}

func putState(stub shim.ChaincodeStubInterface) pb.Response {
	_, parameters := stub.GetFunctionAndParameters()
	if len(parameters) != 2 {
		return shim.Error("Wrong number of arguments supplied. Expected: <milk_id> <operation>")
	}

	key, value := parameters[0], parameters[1]
	err := stub.PutState(key, []byte(value))
	if err != nil {
		return shim.Error("")
	}
	return shim.Success(nil)
}

func main() {
	err := shim.Start(new(MilkManager))
	if err != nil {
		fmt.Printf("Error starting IRS chaincode: %s", err)
	}
}
