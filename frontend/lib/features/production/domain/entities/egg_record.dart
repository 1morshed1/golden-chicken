import 'package:equatable/equatable.dart';

class EggRecord extends Equatable {
  const EggRecord({
    required this.id,
    required this.shedId,
    required this.date,
    required this.totalEggs,
    this.brokenEggs = 0,
    this.soldEggs = 0,
    this.notes,
  });

  final String id;
  final String shedId;
  final DateTime date;
  final int totalEggs;
  final int brokenEggs;
  final int soldEggs;
  final String? notes;

  int get goodEggs => totalEggs - brokenEggs;

  @override
  List<Object?> get props => [id, shedId, date, totalEggs, brokenEggs];
}
