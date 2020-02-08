package chaincode

import "github.com/hyperledger/fabric-contract-api-go/contractapi"

type TransactionContextInterface interface {
	contractapi.TransactionContextInterface
	GetOrderList() *OrderList
}

type TransactionContext struct {
	contractapi.TransactionContext
	orderList *OrderList
}

func (tc *TransactionContext) GetOrderList() *OrderList {
	if tc.orderList == nil {
		tc.orderList = newOrderList(tc)
	}
	return tc.orderList
}