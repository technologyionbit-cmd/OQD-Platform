import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:aqd_ionbit/features/documents/domain/entities/document_source_type.dart';

part 'document.freezed.dart';

@freezed
abstract class Document with _$Document {
  const factory Document({
    required String id,
    required String title,
    required DocumentSourceType sourceType,
    required DateTime createdAt,
    required String sizeLabel,
    /// Set when this document is a generated contract — lets the vault
    /// open the real contract details screen instead of faking a preview.
    String? contractId,
  }) = _Document;
}
