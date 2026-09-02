import '../../../core/errors/result.dart';
import '../domain/group.dart';

abstract class GroupRepository {
  Future<Result<List<Group>>> getGroups();

  Future<Result<void>> createGroup({required String name, String? description});

  Future<Result<void>> joinGroup(String groupId);

  Future<Result<void>> leaveGroup(String groupId);
}
