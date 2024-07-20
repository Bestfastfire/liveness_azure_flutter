import 'dart:convert';

class LivenessResult {
  final String? livenessStatus;
  final String? failureReason;
  final String? verificationStatus;
  final String? confidence;
  final String? resultId;
  final String? digest;
  final String? faceUid;

  const LivenessResult(
      {required this.livenessStatus,
      required this.failureReason,
      required this.verificationStatus,
      required this.confidence,
      required this.resultId,
      required this.digest,
      required this.faceUid});

  factory LivenessResult.fromJson(data) {
    return LivenessResult(
        livenessStatus: data['livenessStatus'],
        failureReason: data['failureReason'],
        verificationStatus: data['verificationStatus'],
        confidence: '${data['confidence']}',
        resultId: data['resultId'],
        digest: data['digest'],
        faceUid: data['faceUID']);
  }

  @override
  String toString() => jsonEncode({
        'livenessStatus': livenessStatus,
        'failureReason': failureReason,
        'verificationStatus': verificationStatus,
        'confidence': confidence,
        'resultId': resultId,
        'digest': digest,
        'faceUid': faceUid
      });
}
