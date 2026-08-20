class UploadedExcelFileModel {
  final int? id;
  final String? fileName;
  final String? url;
  final String? status; // مثلاً: processing / done / failed لو موجود
  final String? createdAt;

  UploadedExcelFileModel({
    this.id,
    this.fileName,
    this.url,
    this.status,
    this.createdAt,
  });

  factory UploadedExcelFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedExcelFileModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse('${json['id'] ?? ''}'),
      fileName:
          json['file_name'] ??
          json['fileName'] ??
          json['filename'] ??
          json['original_name'] ??
          json['originalName'],
      url: json['url'] ?? json['file_url'],
      status: json['status']?.toString(),
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }
}

class UploadedExcelFilesResponseModel {
  final List<UploadedExcelFileModel> data;
  final int? currentPage;
  final int? lastPage;

  UploadedExcelFilesResponseModel({
    required this.data,
    this.currentPage,
    this.lastPage,
  });

  factory UploadedExcelFilesResponseModel.fromJson(dynamic json) {
    // القراءة المرنة: الصفوف بـ data.data حسب التوثيق
    final root = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final outerData = root['data'];

    List<dynamic> rows = [];
    int? currentPage;
    int? lastPage;

    if (outerData is Map<String, dynamic>) {
      // شكل paginator: { data: { data: [...], current_page, last_page } }
      rows = outerData['data'] is List ? outerData['data'] : [];
      currentPage = outerData['current_page'];
      lastPage = outerData['last_page'];
    } else if (outerData is List) {
      // احتياط: لو رجعت مباشرة كـ List
      rows = outerData;
    }

    return UploadedExcelFilesResponseModel(
      data: rows
          .whereType<Map<String, dynamic>>()
          .map((e) => UploadedExcelFileModel.fromJson(e))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }
}