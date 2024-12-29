enum StatusCode { operationSucceeded, operationFailed, serverError, unauth }

extension FetchCode on StatusCode {
  int get code {
    switch (this) {
      case StatusCode.operationSucceeded:
        return 200;
      case StatusCode.operationFailed:
        return 400;
      case StatusCode.unauth:
        return 401;
      case StatusCode.serverError:
        return 500;
    }
  }
}
