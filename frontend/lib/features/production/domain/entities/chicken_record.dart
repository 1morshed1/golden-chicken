import 'package:equatable/equatable.dart';

class ChickenRecord extends Equatable {
  const ChickenRecord({
    required this.id,
    required this.shedId,
    required this.date,
    required this.mortality,
    this.culled = 0,
    this.sold = 0,
    this.notes,
  });

  final String id;
  final String shedId;
  final DateTime date;
  final int mortality;
  final int culled;
  final int sold;
  final String? notes;

  @override
  List<Object?> get props => [id, shedId, date, mortality, culled, sold];
}
