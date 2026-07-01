import { Type } from 'class-transformer';
import {
  IsArray,
  IsIn,
  IsISO8601,
  IsNumber,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { METRICS, MetricKey } from './metrics';

export class SampleDto {
  @IsIn(METRICS as unknown as string[])
  metric!: MetricKey;

  @IsNumber()
  value!: number;

  @IsOptional()
  @IsString()
  unit?: string;

  @IsISO8601()
  recordedAt!: string;

  @IsOptional()
  @IsString()
  source?: string;
}

/// Bulk upload from the band sync.
export class IngestDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SampleDto)
  samples!: SampleDto[];
}
