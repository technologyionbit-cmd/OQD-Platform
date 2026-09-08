import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation_message.freezed.dart';

@freezed
abstract class ConsultationMessage with _$ConsultationMessage {
  const factory ConsultationMessage({
    required String id,
    required String text,
    required DateTime sentAt,
    required bool isFromLawyer,
  }) = _ConsultationMessage;
}
