import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateRoomMetricsDto {
  @IsOptional()
  @IsBoolean()
  isMuted?: boolean;

  @IsOptional()
  @IsBoolean()
  isCameraOn?: boolean;

  @IsOptional()
  @IsBoolean()
  isSpeakerOn?: boolean;
}
