class OrderStatusClass {
  static bool statusOrderIsPending(String status) {
    return (status.contains("pending") || status.contains("on_hold"));
  }

  static bool statusOrderIsDelivered(String status) {
    return (status.contains("delivered") || status.contains("return"));
  }

  static bool statusOrderIsCanceled(String status) {
    return (status.contains("cancel") || status.contains("failed"));
  }

  static bool statusOrderIsPreparing(String status) {
    return (status.contains("preparing") ||
        status.contains("processing") ||
        status.contains("collected") ||
        status.contains("packaged"));
  }

  static bool statusOrderIsShipped(String status) {
    return (status.contains("transferred") ||
        status.contains("shipping") ||
        status.contains("ready_to_shipping") ||
        status.contains("shipped") ||
        status.contains("in_delivery_center") ||
        status.contains("out_for_delivery"));
  }
}
