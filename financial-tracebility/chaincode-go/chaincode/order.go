package chaincode

import (
	"encoding/json"
	"fmt"
)

type State uint

const (
	LAUNCHED State = iota + 1
	PAID
	DISPATCHING
	CONFIRMED
)

func (state State) String() string {
	names := []string{"LAUNCHED", "PAID", "DISPATCHING", "CONFIRMED"}

	if state < LAUNCHED || state > CONFIRMED {
		return "UNKNOWN"
	}

	return names[state-1]
}

type orderAlias Order
type jsonOrder struct {
	*orderAlias
	state State  `json:"currState"`
}

type Order struct {
	OrderID      int64    `json:"orderID"`
	Price        int64    `json:"price"`
	LaunchTime   string   `json:"launchTime"`
	PayTime      string   `json:"payTime"`
	DispatchTime string   `json:"dispatchTime"`
	ConfirmTime  string   `json:"confirmTime"`
	state        State    `metadata:"currState"`
}

func (or *Order) UnmarshalJSON(data []byte) error {
	jcp := jsonOrder{orderAlias: (*orderAlias)(or)}
	err := json.Unmarshal(data, &jcp)
	if err != nil {
		return err
	}
	or.state = jcp.state
	return nil
}

func (or Order) MarshalJSON() ([]byte, error) {
	jcp := jsonOrder{
		orderAlias: (*orderAlias)(&or),
		state: or.state,
	}
	return json.Marshal(&jcp)
}

func (or *Order) GetState() State {
	return or.state
}

func (or *Order) SetState(s State) {
	or.state = s
}

func (or *Order) GetSplitKey() []string {
	return []string{ string(or.OrderID) }
}

func (or *Order) Serialize() ([]byte, error) {
	return json.Marshal(or)
}

func Deserialize(bytes []byte, or *Order) error {
	err := json.Unmarshal(bytes, or)
	if err != nil {
		return fmt.Errorf("Error deserializing order. %s", err.Error())
	}
	return nil
}

