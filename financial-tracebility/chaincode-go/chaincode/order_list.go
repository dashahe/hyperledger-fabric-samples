package chaincode

import ledgerapi "github.com/xiebei1108/hyperledger-fabric-samples/financial-tracebility/chaincode-go/ledger-api"

type ListInterface interface {
	ledgerapi.StateListInterface
}

type OrderList struct {
	stateList *ledgerapi.StateList
}

func (ol *OrderList) AddState(state *Order) error {
	return ol.stateList.AddState(state)
}

func (ol *OrderList) GetState(key string) (*Order, error) {
	order := new(Order)
	err := ol.stateList.GetState(key, order)
	if err != nil {
		return nil, err
	}
	return order, nil
}

func (ol *OrderList) UpdateState(state *Order) error {
	return ol.AddState(state)
}

func newOrderList(ctx TransactionContextInterface) *OrderList {
	stateList := new(ledgerapi.StateList)
	stateList.Ctx = ctx
	stateList.Name = "org.example.finan-trace"
	stateList.Deserialize = func(bytes []byte, state ledgerapi.StateInterface) error {
		return Deserialize(bytes, state.(*Order))
	}

	list := new(OrderList)
	list.stateList = stateList
	return list
}

