class SmartSpeedTest {
  final String id;
  final String testResultId;
  final String testName;
  final String testTypeName;
  final DateTime testDateUtc;
  final bool isValid;
  final int deviceCount;
  final int repCount;
  final RunningSummaryFields? runningSummaryFields;

  SmartSpeedTest({
    required this.id,
    required this.testResultId,
    required this.testName,
    required this.testTypeName,
    required this.testDateUtc,
    required this.isValid,
    required this.deviceCount,
    required this.repCount,
    this.runningSummaryFields,
  });

  factory SmartSpeedTest.fromJson(Map<String, dynamic> json) {
    return SmartSpeedTest(
      id: json['id'],
      testResultId: json['testResultId'],
      testName: json['testName'],
      testTypeName: json['testTypeName'],
      testDateUtc: DateTime.parse(json['testDateUtc']),
      isValid: json['isValid'],
      deviceCount: json['deviceCount'],
      repCount: json['repCount'],
      runningSummaryFields: json['runningSummaryFields'] != null
          ? RunningSummaryFields.fromJson(json['runningSummaryFields'])
          : null,
    );
  }
}

class RunningSummaryFields {
  final double totalTimeSeconds;
  final double bestSplitSeconds;
  final double splitAverageSeconds;
  final GateSummaryFields? gateSummaryFields;

  RunningSummaryFields({
    required this.totalTimeSeconds,
    required this.bestSplitSeconds,
    required this.splitAverageSeconds,
    this.gateSummaryFields,
  });

  factory RunningSummaryFields.fromJson(Map<String, dynamic> json) {
    return RunningSummaryFields(
      totalTimeSeconds: json['totalTimeSeconds']?.toDouble() ?? 0,
      bestSplitSeconds: json['bestSplitSeconds']?.toDouble() ?? 0,
      splitAverageSeconds: json['splitAverageSeconds']?.toDouble() ?? 0,
      gateSummaryFields: json['gateSummaryFields'] != null
          ? GateSummaryFields.fromJson(json['gateSummaryFields'])
          : null,
    );
  }
}

class GateSummaryFields {
  final double splitOne;
  final double splitTwo;
  final double splitThree;
  final double splitFour;

  GateSummaryFields({
    required this.splitOne,
    required this.splitTwo,
    required this.splitThree,
    required this.splitFour,
  });

  factory GateSummaryFields.fromJson(Map<String, dynamic> json) {
    return GateSummaryFields(
      splitOne: json['splitOne']?.toDouble() ?? 0,
      splitTwo: json['splitTwo']?.toDouble() ?? 0,
      splitThree: json['splitThree']?.toDouble() ?? 0,
      splitFour: json['splitFour']?.toDouble() ?? 0,
    );
  }
}
