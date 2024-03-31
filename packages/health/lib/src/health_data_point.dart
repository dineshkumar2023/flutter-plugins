part of '../health.dart';

/// A [HealthDataPoint] object corresponds to a data point capture from
/// Apple HealthKit or Google Fit or Google Health Connect with a [HealthValue]
/// as value.
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class HealthDataPoint {
  /// The quantity value of the data point
  HealthValue value;

  /// The type of the data point.
  HealthDataType type;

  /// The data point type as a string.
  String get typeString => type.name;

  /// The unit of the data point.
  HealthDataUnit unit;

  /// The data point unit as a string.
  String get unitString => unit.name;

  /// The start of the time interval.
  DateTime dateFrom;

  /// The end of the time interval.
  DateTime dateTo;

  /// The software platform of the data point.
  PlatformType platform;

  /// The id of the device from which the data point was fetched.
  String deviceId;

  /// The id of the source from which the data point was fetched.
  String sourceId;

  /// The name of the source from which the data point was fetched.
  String sourceName;

  /// The user entered state of the data point.
  bool isManualEntry;

  /// The summary of the workout data point, if available.
  WorkoutSummary workoutSummary;

  HealthDataPoint({
    this.value,
    this.type,
    this.unit,
    this.dateFrom,
    this.dateTo,
    this.platform,
    this.deviceId,
    this.sourceId,
    this.sourceName,
    this.isManualEntry = false,
    this.workoutSummary,
  }) {
    // set the value to minutes rather than the category
    // returned by the native API
    if (type == HealthDataType.MINDFULNESS ||
        type == HealthDataType.HEADACHE_UNSPECIFIED ||
        type == HealthDataType.HEADACHE_NOT_PRESENT ||
        type == HealthDataType.HEADACHE_MILD ||
        type == HealthDataType.HEADACHE_MODERATE ||
        type == HealthDataType.HEADACHE_SEVERE ||
        type == HealthDataType.SLEEP_IN_BED ||
        type == HealthDataType.SLEEP_ASLEEP ||
        type == HealthDataType.SLEEP_AWAKE ||
        type == HealthDataType.SLEEP_DEEP ||
        type == HealthDataType.SLEEP_LIGHT ||
        type == HealthDataType.SLEEP_REM ||
        type == HealthDataType.SLEEP_OUT_OF_BED) {
      value = _convertMinutes();
    }
  }

  /// Converts dateTo - dateFrom to minutes.
  NumericHealthValue _convertMinutes() => NumericHealthValue(
      numericValue:
          (dateTo.millisecondsSinceEpoch - dateFrom.millisecondsSinceEpoch) / (1000 * 60));

  /// Create a [HealthDataPoint] from json.
  factory HealthDataPoint.fromJson(Map<String, dynamic> json) => _$HealthDataPointFromJson(json);

  /// Convert this [HealthDataPoint] to json.
  Map<String, dynamic> toJson() => _$HealthDataPointToJson(this);

  /// Create a [HealthDataPoint] based on a health data point from native data format.
  factory HealthDataPoint.fromHealthDataPoint(
    HealthDataType dataType,
    dynamic dataPoint,
  ) {
    // Handling different [HealthValue] types
    // HealthValue value = switch (dataType) {
    //   HealthDataType.AUDIOGRAM =>
    //     AudiogramHealthValue.fromHealthDataPoint(dataPoint),
    //   HealthDataType.WORKOUT =>
    //     WorkoutHealthValue.fromHealthDataPoint(dataPoint),
    //   HealthDataType.ELECTROCARDIOGRAM =>
    //     ElectrocardiogramHealthValue.fromHealthDataPoint(dataPoint),
    //   HealthDataType.NUTRITION =>
    //     NutritionHealthValue.fromHealthDataPoint(dataPoint),
    //   _ => NumericHealthValue.fromHealthDataPoint(dataPoint),
    // };

    HealthValue value;
    switch (dataType) {
      case HealthDataType.AUDIOGRAM:
        value = AudiogramHealthValue.fromHealthDataPoint(dataPoint);
        break;
      case HealthDataType.WORKOUT:
        value = WorkoutHealthValue.fromHealthDataPoint(dataPoint);
        break;
      case HealthDataType.ELECTROCARDIOGRAM:
        value = ElectrocardiogramHealthValue.fromHealthDataPoint(dataPoint);
        break;
      case HealthDataType.NUTRITION:
        value = NutritionHealthValue.fromHealthDataPoint(dataPoint);
        break;
      default:
        value = NumericHealthValue.fromHealthDataPoint(dataPoint);
        break;
    }

    final DateTime from = DateTime.fromMillisecondsSinceEpoch(dataPoint['date_from'] as int);
    final DateTime to = DateTime.fromMillisecondsSinceEpoch(dataPoint['date_to'] as int);
    final String sourceId = dataPoint["source_id"] as String;
    final String sourceName = dataPoint["source_name"] as String;
    final bool isManualEntry = dataPoint["is_manual_entry"] as bool ?? false;
    final unit = dataTypeToUnit[dataType] ?? HealthDataUnit.UNKNOWN_UNIT;

    // Set WorkoutSummary, if available.
    WorkoutSummary workoutSummary;
    if (dataPoint["workout_type"] != null ||
        dataPoint["total_distance"] != null ||
        dataPoint["total_energy_burned"] != null ||
        dataPoint["total_steps"] != null) {
      workoutSummary = WorkoutSummary.fromHealthDataPoint(dataPoint);
    }

    return HealthDataPoint(
      value: value,
      type: dataType,
      unit: unit,
      dateFrom: from,
      dateTo: to,
      platform: Health().platformType,
      deviceId: Health().deviceId,
      sourceId: sourceId,
      sourceName: sourceName,
      isManualEntry: isManualEntry,
      workoutSummary: workoutSummary,
    );
  }

  @override
  String toString() => """$runtimeType -
    value: ${value.toString()},
    unit: ${unit.name},
    dateFrom: $dateFrom,
    dateTo: $dateTo,
    dataType: ${type.name},
    platform: $platform,
    deviceId: $deviceId,
    sourceId: $sourceId,
    sourceName: $sourceName
    isManualEntry: $isManualEntry
    workoutSummary: $workoutSummary""";

  @override
  bool operator ==(Object other) =>
      other is HealthDataPoint &&
      value == other.value &&
      unit == other.unit &&
      dateFrom == other.dateFrom &&
      dateTo == other.dateTo &&
      type == other.type &&
      platform == other.platform &&
      deviceId == other.deviceId &&
      sourceId == other.sourceId &&
      sourceName == other.sourceName &&
      isManualEntry == other.isManualEntry;

  @override
  int get hashCode =>
      Object.hash(value, unit, dateFrom, dateTo, type, platform, deviceId, sourceId, sourceName);
}
