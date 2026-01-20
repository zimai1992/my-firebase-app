class PredictionResult {
  final DateTime? runoutDate;
  final String confidence; // 'High', 'Medium', 'Low'
  final String message;
  final int? daysRemaining;

  PredictionResult({
    this.runoutDate,
    required this.confidence,
    required this.message,
    this.daysRemaining,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(json['runoutDate'] ?? '');
    } catch (e) {
      parsedDate = null;
    }

    int? days;
    if (parsedDate != null) {
      days = parsedDate.difference(DateTime.now()).inDays;
    }

    return PredictionResult(
      runoutDate: parsedDate,
      confidence: json['confidence'] ?? 'Low',
      message: json['message'] ?? 'Unable to predict',
      daysRemaining: days,
    );
  }

  factory PredictionResult.error(String errorMsg) {
    return PredictionResult(
      confidence: 'Low',
      message: errorMsg,
    );
  }
}
