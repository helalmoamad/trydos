
abstract class Failure {
  final String message;

  const Failure(this.message);
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({String? message}) : super(message ?? "ServerFailure");
}

class OperationFailedFailure extends Failure {
  const OperationFailedFailure({String? message}) : super(message ?? "OperationFailedFailure");
}

class DioFailure extends Failure {
  const DioFailure({String? message}) : super(message ?? "DioFailure");
}


// class TryAgainFailure extends Failure {
//   const TryAgainFailure({String? message}) : super(message ?? "DioFailure");
// }