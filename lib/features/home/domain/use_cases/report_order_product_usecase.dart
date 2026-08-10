import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:mime_type/mime_type.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/response_only_message_model.dart';
import '../repositories/home_repository.dart';

/// الإبلاغ عن منتج داخل طلب — `POST /customer/order/report`.
///
/// يُقبل البلاغ **مرّة واحدة** لكل منتج؛ بعدها يعيد الخادم `is_reported`
/// على تفصيل المنتج فتُعطَّل البطاقة في الواجهة.
@injectable
class ReportOrderProductUseCase
    extends UseCase<ResponseOnlyMessageModel, ReportOrderProductParams> {
  final HomeRepository repository;

  ReportOrderProductUseCase(this.repository);

  @override
  Future<Either<Failure, ResponseOnlyMessageModel>> call(
    ReportOrderProductParams params,
  ) async {
    return repository.reportOrderProduct(await params.map());
  }
}

/// نقطة بلاغ واحدة: مجموعة (`point`) وما اختاره المستخدم منها (`values`).
class ReportPoint {
  const ReportPoint({required this.point, required this.values});

  /// مفتاح المجموعة: `product_quality` · `delivery_time` ·
  /// `delivery_worker` · `delivery_car`.
  final String point;

  /// مفاتيح الخيارات المُختارة داخل المجموعة (`damaged`، `too_late`، …).
  final List<String> values;
}

class ReportOrderProductParams {
  ReportOrderProductParams({
    required this.orderId,
    required this.orderDetailId,
    required this.productId,
    required this.orderGroupId,
    required this.points,
    this.note = '',
    this.image,
  });

  final int orderId;
  final int orderDetailId;
  final int productId;
  final String orderGroupId;

  /// مجموعة واحدة على الأقلّ بخيار واحد على الأقلّ — تتحقّق منه الواجهة قبل
  /// تفعيل زرّ الإرسال.
  final List<ReportPoint> points;

  /// اختيارية.
  final String note;

  /// اختيارية، وصورة واحدة فقط. وجودها يحوّل الطلب إلى `multipart/form-data`.
  final File? image;

  /// عند وجود صورة يُرسَل الطلب `FormData`، وإلا فـ JSON — كما تنصّ المواصفة.
  Future<Map<String, dynamic>> map() async {
    if (image == null) {
      return {
        'data': {
          'order_id': orderId,
          'order_detail_id': orderDetailId,
          'product_id': productId,
          'order_group_id': orderGroupId,
          'points': points
              .map((p) => {'point': p.point, 'values': p.values})
              .toList(),
          'note': note,
        },
      };
    }

    final String fileName = image!.path.split('/').last;
    final List<String> mimeParts = (mime(fileName) ?? '').split('/');

    // FormData.fromMap لا يمثّل الفهارس المتداخلة (points[0][values][])،
    // فتُضاف الحقول واحداً واحداً بأسمائها الحرفية كما ينتظرها الخادم.
    final FormData data = FormData();
    data.fields
      ..add(MapEntry('order_id', orderId.toString()))
      ..add(MapEntry('order_detail_id', orderDetailId.toString()))
      ..add(MapEntry('product_id', productId.toString()))
      ..add(MapEntry('order_group_id', orderGroupId))
      ..add(MapEntry('note', note));

    for (int i = 0; i < points.length; i++) {
      data.fields.add(MapEntry('points[$i][point]', points[i].point));
      for (final String value in points[i].values) {
        data.fields.add(MapEntry('points[$i][values][]', value));
      }
    }

    data.files.add(
      MapEntry(
        'image',
        await MultipartFile.fromFile(
          image!.path,
          filename: fileName,
          contentType: mimeParts.length == 2
              ? MediaType(mimeParts[0], mimeParts[1])
              : null,
        ),
      ),
    );

    return {'data': data};
  }
}
