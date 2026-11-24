/// A lawyer waiting for review, with the documents they sent.
class PendingLawyer {
  const PendingLawyer({
    required this.lawyerProfileId,
    required this.fullName,
    required this.email,
    required this.barLicenseNumber,
    required this.documents,
    this.phone,
    this.submittedAt,
  });

  factory PendingLawyer.fromJson(Map<String, dynamic> json) => PendingLawyer(
        lawyerProfileId: json['lawyerProfileId'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        barLicenseNumber: json['barLicenseNumber'] as String,
        submittedAt: json['submittedAt'] == null ? null : DateTime.parse(json['submittedAt'] as String),
        documents: [for (final d in json['documents'] as List<dynamic>) VerificationDocument.fromJson(d as Map<String, dynamic>)],
      );

  final String lawyerProfileId;
  final String fullName;
  final String email;
  final String? phone;
  final String barLicenseNumber;
  final DateTime? submittedAt;
  final List<VerificationDocument> documents;
}

class VerificationDocument {
  const VerificationDocument({required this.id, required this.originalName, required this.mimeType, required this.sizeBytes});

  factory VerificationDocument.fromJson(Map<String, dynamic> json) => VerificationDocument(
        id: json['id'] as String,
        originalName: json['originalName'] as String,
        mimeType: json['mimeType'] as String,
        sizeBytes: (json['sizeBytes'] as num).toInt(),
      );

  final String id;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
}
