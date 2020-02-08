package chaincode.java;

import org.hyperledger.fabric.shim.ChaincodeStub;

public class Context extends org.hyperledger.fabric.contract.Context {

    private OrderList orderList;

    Context(ChaincodeStub stub) {
        super(stub);
        this.orderList = new OrderList(this);
    }

    public OrderList getOrderList() {
        return this.orderList;
    }
}
