import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trydos/core/data/model/upload_ticket_response.dart';
import 'package:trydos/core/domin/repositories/common_use_repository.dart';
import 'package:trydos/core/error/failures.dart';
import 'package:trydos/core/use_case/use_case.dart';

/// الخطوة الأولى من تدفّق الرفع المُقيَّد: `POST /gated/ticket`.
///
/// التذكرة صالحة 120 ثانية **ولمرّة واحدة**، لذلك تُستخرَج مباشرة قبل الرفع،
/// وكل إعادة محاولة تحتاج تذكرة جديدة.
@injectable
class MintUploadTicketUseCase
    extends UseCase<UploadTicketResponseModel, MintUploadTicketParams> {
  final CommonUseRepository repository;

  MintUploadTicketUseCase(this.repository);

  @override
  Future<Either<Failure, UploadTicketResponseModel>> call(
    MintUploadTicketParams params,
  ) async {
    return repository.mintUploadTicket(await params.map());
  }
}

class MintUploadTicketParams {
  MintUploadTicketParams({this.folder, this.count, this.story});

  /// مسار مجلّد بمقاطع `[A-Za-z0-9._-]` يفصلها `/`.
  /// بلا `/` في أوّله أو آخره، وبلا `.` أو `..`.
  final String? folder;

  /// عدد الملفات المتوقّعة (للرفع الجماعي). الحدّ الأعلى 50.
  final int? count;

  /// `true` لرفع الستوري — يخفض الحدّ الأعلى للحجم إلى 10 ميغابايت.
  final bool? story;

  Future<Map<String, dynamic>> map() async {
    // كل الحقول اختيارية: لا تُرسَل إلا ما حُدِّد فعلاً
    final Map<String, dynamic> body = {};
    if (folder != null && folder!.isNotEmpty) body['folder'] = folder;
    if (count != null) body['count'] = count;
    if (story != null) body['story'] = story;

    return {'data': body};
  }
}
