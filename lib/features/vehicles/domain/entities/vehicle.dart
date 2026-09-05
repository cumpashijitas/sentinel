import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

/// A rider's motorcycle — 1:1 with `public.vehicles` in Postgres (see
/// `supabase/migrations/20260827210002_vehicles.sql`). Strictly private:
/// RLS only ever lets the owner see or edit their own rows.
@freezed
abstract class Vehicle with _$Vehicle {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Vehicle({
    required String id,
    required String ownerId,
    required String brand,
    required String model,
    int? year,
    String? plate,
    String? color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}
