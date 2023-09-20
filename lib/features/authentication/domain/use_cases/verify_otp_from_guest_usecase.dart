// import 'package:dartz/dartz.dart';
// import 'package:injectable/injectable.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/use_case/use_case.dart';
// import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
// import '../repositories/auth_repository.dart';
//
// @injectable
// class VerifyOtpFromGuestUseCase implements UseCase<VerifyOtpFromGuestResponseModel, VerifyOtpFromGuestParams> {
//   VerifyOtpFromGuestUseCase(this.repository);
//
//   final AuthRepository repository;
//
//   @override
//   Future<Either<Failure, VerifyOtpFromGuestResponseModel>> call(
//       VerifyOtpFromGuestParams params) async {
//     return repository.verifyOtpFromGuest(params.map);
//   }
// }
//
// class VerifyOtpFromGuestParams {
//   String verificationId;
//   String otp;
//
//   VerifyOtpFromGuestParams({
//     required this.verificationId,
//     required this.otp,
//   });
//   Map<String, dynamic> get map =>{
//     "otp" :otp,
//     "verificationId" :verificationId,
//   };
// }
