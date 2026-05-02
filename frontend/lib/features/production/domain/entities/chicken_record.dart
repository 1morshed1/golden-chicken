import 'package:equatable/equatable.dart';

class ChickenRecord extends Equatable {
  const ChickenRecord({
    required this.id,
    required this.shedId,
    required this.date,
    required this.totalBirds,
    this.additions = 0,
    this.mortality = 0,
    this.notes,
  });

  final String id;
  final String shedId;
  final DateTime date;
  final int totalBirds;
  final int additions;
  final int mortality;
  final String? notes;

  @override
  List<Object?> get props => [id, shedId, date, totalBirds, mortality];
}
