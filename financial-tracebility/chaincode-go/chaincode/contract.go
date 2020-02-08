package chaincode

import (
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric-protos-go/ledger/queryresult"
)

type Contract struct {
	*contractapi.Contract
}

func (c *Contract) Instantiate() {
	fmt.Println("Instantiated")
}

func (c *Contract) Launch(ctx TransactionContextInterface, orderID, price int64, time string) (*Order, error) {
	order, _ := ctx.GetOrderList().GetState(string(orderID))
	if order != nil {
		return nil, fmt.Errorf("existing order with order id %d", orderID)
	}

	order = new(Order)
	order.OrderID = orderID
	order.Price = price
	order.LaunchTime = time
	order.SetState(LAUNCHED)

	err := ctx.GetOrderList().AddState(order)
	if err != nil {
		return nil, err
	}
	return order, nil
}

func (c *Contract) Pay(ctx TransactionContextInterface, orderID int64, time string) (*Order, error) {
	order, err := ctx.GetOrderList().GetState(string(orderID))
	if err != nil {
		return nil, fmt.Errorf("can't get order with id %d", orderID)
	}

	if state := order.GetState(); state != LAUNCHED {
		return nil, fmt.Errorf("order %d's state is %s", orderID, state.String())
	}

	order.PayTime = time
	order.SetState(PAID)

	err = ctx.GetOrderList().UpdateState(order)
	if err != nil {
		return nil, err
	}
	return order, nil
}

func (c *Contract) Dispatch(ctx TransactionContextInterface, orderID int64, time string) (*Order, error) {
	order, err := ctx.GetOrderList().GetState(string(orderID))
	if err != nil {
		return nil, fmt.Errorf("can't get order with id %d", orderID)
	}

	if state := order.GetState(); state != PAID {
		return nil, fmt.Errorf("order %d's state is %s", orderID, state.String())
	}

	order.DispatchTime = time
	order.SetState(DISPATCHING)

	err = ctx.GetOrderList().UpdateState(order)
	if err != nil {
		return nil, err
	}
	return order, nil
}

func (c *Contract) Confirm(ctx TransactionContextInterface, orderID int64, time string) (*Order, error) {
	order, err := ctx.GetOrderList().GetState(string(orderID))
	if err != nil {
		return nil, fmt.Errorf("can't get order with id %d", orderID)
	}

	if state := order.GetState(); state != DISPATCHING {
		return nil, fmt.Errorf("order %d's state is %s", orderID, state.String())
	}

	order.ConfirmTime = time
	order.SetState(CONFIRMED)

	err = ctx.GetOrderList().UpdateState(order)
	if err != nil {
		return nil, err
	}
	return order, nil
}

func (c *Contract) GetOrder(ctx TransactionContextInterface, orderID int64) (*Order, error) {
	order, err := ctx.GetOrderList().GetState(string(orderID))
	if err != nil {
		return nil, fmt.Errorf("can't get order with id %d", orderID)
	}
	return order, nil
}

func (c *Contract) GetHistory(ctx TransactionContextInterface, orderID int64) ([]byte, error) {
	histories, err := ctx.GetStub().GetHistoryForKey(string(orderID))
	if err != nil {
		return nil, fmt.Errorf("can't get history for %d", orderID)
	}
	var result string
	result += "{"
	for histories.HasNext() {
		if history, err := histories.Next(); err != nil {
			break
		} else {
			result += historyToJsonString(history) + ","
		}
	}
	result += "}"
	return []byte(result), nil
}

func historyToJsonString(history *queryresult.KeyModification) string {
	jsonStr := fmt.Sprintf("{\"transactionID\": \"%s\", \"timestamp\": \"%s\", transactionValue: \"%s\"}",
		history.GetTxId(), history.GetTimestamp().String(), history.GetValue())
	return jsonStr
}
