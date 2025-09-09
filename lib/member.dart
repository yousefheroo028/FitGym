import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 1)
class Member extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  DateTime startDate;
  @HiveField(2)
  DateTime endDate;
  @HiveField(3)
  final double subscriptionBudget;
  @HiveField(4)
  String? profileImageURL;
  @HiveField(5)
  final String phoneNumber;

  Member({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.subscriptionBudget,
    this.profileImageURL,
    required this.phoneNumber,
  });

  int get getRemainingTime => endDate.add(const Duration(days: 1)).difference(DateTime.now()).inDays;

  void renew() {
    endDate = DateTime.now().add(const Duration(days: 30));
    startDate = DateTime.now();
  }
}
