package chaincode.java;

import chaincode.java.ledgerapi.State;
import chaincode.java.ledgerapi.StateList;

import java.util.List;

public class OrderList implements StateList {

    private StateList stateList;

    OrderList(Context ctx) {
        this.stateList = StateList.getStateList(ctx, OrderList.class.getSimpleName(), Order::deserialize);
    }

    @Override
    public StateList addState(State state) {
        stateList.addState(state);
        return this;
    }

    @Override
    public Order getState(String key) {
        return (Order) stateList.getState(key);
    }

    @Override
    public StateList updateState(State state) {
        this.addState(state);
        return this;
    }
}
