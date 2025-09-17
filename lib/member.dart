import 'package:dartx/dartx.dart';
import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 1)
class Member extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  DateTime startDate;
  @HiveField(2)
  DateTime endDate;
  @HiveField(3)
  double subscriptionBudget;
  @HiveField(4)
  String? profileImageURL;
  @HiveField(5)
  String phoneNumber;

  Member({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.subscriptionBudget,
    this.profileImageURL,
    required this.phoneNumber,
  });

  int getRemainingTime() => endDate.date.difference(DateTime.now().date).inDays;

  int renew({int months = 1}) {
    startDate = DateTime.now();
    endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + months * 30 - 1);
    return getRemainingTime();
  }
}
