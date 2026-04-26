enum ConstOrderStatus {
  all,
  in_progress,
  collected,
  returned,
  canceled,
  
}

String getStatusLabel(ConstOrderStatus status) {
  switch (status) {
    case ConstOrderStatus.in_progress:
      return "In Progress";
    case ConstOrderStatus.collected:
      return "Collected";
    case ConstOrderStatus.returned:
      return "Returned";
    case ConstOrderStatus.canceled:
      return "Canceled";
    case ConstOrderStatus.all:
      return "All";
  }
}

extension ConstOrderStatusApi on ConstOrderStatus {
  String get apiValue => name;
}
