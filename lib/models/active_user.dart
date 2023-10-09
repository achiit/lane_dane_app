import 'package:lane_dane/models/users.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ActiveUser {
  @Id()
  int id;
  DateTime lastActivityTime;

  ToOne<Users> user = ToOne<Users>();

  ActiveUser({
    this.id = 0,
    required this.lastActivityTime,
    required this.user,
  });
}
