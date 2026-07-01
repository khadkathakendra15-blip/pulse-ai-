/// Metric identifiers stored on HealthSample.metric. Kept as a string union
/// (portable across SQLite and Postgres) rather than a DB enum.
export const METRICS = [
  'HEART_RATE',
  'HRV',
  'SPO2',
  'STEPS',
  'SLEEP_MINUTES',
  'STRESS',
  'TEMPERATURE',
  'BATTERY',
] as const;

export type MetricKey = (typeof METRICS)[number];

/// Metric → the LatestVitals field it populates.
export const METRIC_TO_VITAL: Record<MetricKey, string> = {
  HEART_RATE: 'heartRate',
  HRV: 'hrv',
  SPO2: 'spo2',
  STEPS: 'steps',
  SLEEP_MINUTES: 'sleepMinutes',
  STRESS: 'stress',
  TEMPERATURE: 'temperature',
  BATTERY: 'battery',
};
