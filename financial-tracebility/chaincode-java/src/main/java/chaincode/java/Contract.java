package chaincode.java;

import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Transaction;

import chaincode.java.Context;
import org.hyperledger.fabric.shim.ChaincodeStub;
import org.hyperledger.fabric.shim.ledger.KeyModification;

import java.util.List;
import java.util.logging.Logger;

public class Contract implements ContractInterface {
    private final static Logger LOG = Logger.getLogger(Contract.class.getName());

    private final String LAUNCHED = "LAUNCHED";
    private final String PAID = "PAID";
    private final String DISPATCHED = "DISPATCHED";
    private final String CONFIRMED = "CONFIRMED";

    @Override
    public Context createContext(ChaincodeStub stub) {
        return new Context(stub);
    }

    public Contract() {

    }

    @Transaction
    public void instantiate(Context ctx) {
        // No implementation required with this example
        // It could be where data migration is performed, if necessary
        LOG.info("No data migration to perform");
    }

    @Transaction
    public Order launchOrder(Context ctx, String orderID, Integer price, String time) {
        Order order = ctx.getOrderList().getState(orderID);
        if (order != null) {
            throw new RuntimeException("order with id " + orderID + " already exist");
        }

        order = new Order(orderID);
        order.setPrice(price).setlaunchTime(time).setState(LAUNCHED);

        ctx.getOrderList().addState(order);

        return order;
    }

    @Transaction
    public Order payOrder(Context ctx, String orderID, String time) {
        Order order = ctx.getOrderList().getState(orderID);
        if (order == null) {
            throw new RuntimeException("order with id " + orderID + " not launched");
        }

        if (!order.getState().equals(LAUNCHED)) {
            throw new RuntimeException("order with id " + orderID + " 's state is " + order.getState());
        }

        order.setPayTime(time).setState(PAID);
        ctx.getOrderList().updateState(order);

        return order;
    }

    @Transaction
    public Order dispatch(Context ctx, String orderID, String time) {
        Order order = ctx.getOrderList().getState(orderID);

        if (order == null) {
            throw new RuntimeException("order with id " + orderID + " not launched");
        }

        if (!order.getState().equals(PAID)) {
            throw new RuntimeException("order with id " + orderID + " 's state is " + order.getState());
        }

        order.setDispatchTime(time).setState(DISPATCHED);
        ctx.getOrderList().updateState(order);

        return order;
    }

    @Transaction
    public Order confirm(Context ctx, String orderID, String time) {
        Order order = ctx.getOrderList().getState(orderID);
        if (order == null) {
            throw new RuntimeException("order with id " + orderID + " not launched");
        }

        if (!order.getState().equals(DISPATCHED)) {
            throw new RuntimeException("order with id " + orderID + " 's state is " + order.getState());
        }

        order.setConfirmTime(time).setState(CONFIRMED);
        ctx.getOrderList().updateState(order);

        return order;
    }

    @Transaction
    public Order getOrder(Context ctx, String orderID) {
        Order order = ctx.getOrderList().getState(orderID);
        if (order == null) {
            throw new RuntimeException("order with id " + orderID + " not found");
        }
        return order;
    }

    @Transaction
    public String getHistory(Context ctx, String orderID) {
        StringBuilder result = new StringBuilder();
        for (KeyModification km : ctx.getStub().getHistoryForKey(orderID)) {
            result.append("[transaction " + km.getTxId() + "]\n");
            result.append("timestamp: " + km.getTimestamp().toString());
            result.append(km.getStringValue() + "\n");
        }
        return result.toString();
    }
}