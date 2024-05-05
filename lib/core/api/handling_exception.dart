import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../enums/status_code_type.dart';
import '../error/exception.dart';
import '../error/failures.dart';

typedef RequestCall<T> = Future<T> Function();

abstract class HandlingExceptionRequest {
  void prettyPrinterError(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).e(message);
  }

  void prettyPrinterWtf(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).wtf(message);
  }

  void prettyPrinterI(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).i(message);
  }

  void prettyPrinterV(final String message) {
    Logger(printer: PrettyPrinter(methodCount: 0)).v(message);
  }

  Exception getException({required int statusCode, String? message}) {
    //if(tryAgain==true)
    //return TryAgainException
    if (statusCode == StatusCode.operationFailed.code) {
      return OperationFailedException(message: message);
    } else {
      return ServerException(message: message);
    }
  }

  Future<Either<Failure, T>> handlingExceptionRequest<T>(
      {required RequestCall<T> tryCall}) async {
    try {
      T response = await tryCall();
      return Right(response);
    } on ServerException {
      // Fluttertoast.showToast(msg: 'sssssss',backgroundColor: Colors.yellow);
      prettyPrinterError("***|| ServerException ||*** ");
      return const Left(ServerFailure("ServerException"));
    } on DioException catch (e, s) {
      // Fluttertoast.showToast(msg: 'aaaaaaaaaaaa',backgroundColor: Colors.yellow);

      prettyPrinterError("***|| DioError ||*** \n $s");
      return Left(DioFailure(message: e.response?.data['errors']?[0]['code']));
    } catch (e, stackTrace) {
      prettyPrinterError(
        "***|| CATCH ERROR ||***"
        "\n $e"
        "***|| Stack Trace ||***"
        "\n $stackTrace",
      );
      return const Left(ServerFailure("ServerException"));
    }
  }
}
