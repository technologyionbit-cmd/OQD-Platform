import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_mock_data_source.dart';
import 'package:aqd_ionbit/features/consultation_room/data/datasources/consultation_room_remote_data_source.dart';

/// The ONE place that decides which [ConsultationRoomRemoteDataSource]
/// implementation the app runs against. Swapping in a real WebRTC/Agora/
/// Twilio-backed implementation later means changing only this file.
final consultationRoomRemoteDataSourceProvider = Provider<ConsultationRoomRemoteDataSource>((ref) => ConsultationRoomMockDataSource());
