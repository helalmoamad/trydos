abstract class Failure {
  final String message;

  const Failure(this.message);
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(String s, {String? message})
      : super(message ?? "ServerFailure");
}

class OperationFailedFailure extends Failure {
  const OperationFailedFailure({String? message})
      : super(message ?? "OperationFailedFailure");
}

class DioFailure extends Failure {
  const DioFailure({String? message}) : super(message ?? "DioFailure");
}

class TryAgainFailure extends Failure {
  final int tryCount;
  const TryAgainFailure({String? message, required this.tryCount})
      : super(message ?? "TryAgainFailure");
}
