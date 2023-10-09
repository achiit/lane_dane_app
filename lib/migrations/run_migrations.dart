import 'package:lane_dane/migrations/active_user_to_user_group_entity_23_03_2023.dart';

runMigrations() {
  ActiveUserToUserGroupEntityMigration activeUserToUserGroup =
      ActiveUserToUserGroupEntityMigration();

  activeUserToUserGroup.migrate();
}
