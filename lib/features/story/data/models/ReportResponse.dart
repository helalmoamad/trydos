class ReportResponse {
  final String message;
  final int reportId;
  final bool isSuspicious;

  ReportResponse({
    required this.message,
    required this.reportId,
    required this.isSuspicious,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      message: json['message'],
      reportId: json['reportId'],
      isSuspicious: json['isSuspicious'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'reportId': reportId,
      'isSuspicious': isSuspicious,
    };
  }
}