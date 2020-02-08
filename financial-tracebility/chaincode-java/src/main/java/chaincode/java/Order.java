package chaincode.java;

import chaincode.java.ledgerapi.State;
import org.json.JSONObject;

import static java.nio.charset.StandardCharsets.UTF_8;

public class Order extends State {
    private String orderID;
    private String launchTime;
    private String payTime;
    private String dispatchTime;
    private String confirmTime;
    private String state;
    private Integer price;

    public Order(String orderID) {
        this.orderID = orderID;
    }

     private Order(String orderID, String launchTime, String payTime, String dispatchTime,
                 String confirmTime, String state, Integer price) {
        this.orderID = orderID;
        this.launchTime = launchTime;
        this.payTime = payTime;
        this.dispatchTime = dispatchTime;
        this.confirmTime = confirmTime;
        this.state = state;
        this.price = price;
    }

    public String getOrderID() {
        return orderID;
    }

    public Order setOrderID(String orderID) {
        this.orderID = orderID;
        return this;
    }

    public String getlaunchTime() {
        return launchTime;
    }

    public Order setlaunchTime(String launchTime) {
        this.launchTime = launchTime;
        return this;
    }

    public String getPayTime() {
        return payTime;
    }

    public Order setPayTime(String payTime) {
        this.payTime = payTime;
        return this;
    }

    public String getDispatchTime() {
        return dispatchTime;
    }

    public Order setDispatchTime(String dispatchTime) {
        this.dispatchTime = dispatchTime;
        return this;
    }

    public String getConfirmTime() {
        return confirmTime;
    }

    public Order setConfirmTime(String confirmTime) {
        this.confirmTime = confirmTime;
        return this;
    }

    public String getState() {
        return state;
    }

    public Order setState(String state) {
        this.state = state;
        return this;
    }

    public Integer getPrice() {
        return price;
    }

    public Order setPrice(Integer price) {
        this.price = price;
        return this;
    }

    public static Order deserialize(byte[] data) {
        JSONObject json = new JSONObject(new String(data, UTF_8));

        String orderID = json.getString("orderID");
        String launchTime = json.getString("launchTime");
        String payTime = json.getString("payTime");
        String dispatchTime = json.getString("dispatchTime");
        String confirmTime = json.getString("confirmTime");
        String state = json.getString("state");
        Integer price = json.getInt("price");

        return new Order(orderID, launchTime, payTime, dispatchTime, confirmTime, state, price);
    }

}
