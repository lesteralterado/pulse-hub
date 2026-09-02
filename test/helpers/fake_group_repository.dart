import 'package:pulsehub/core/errors/result.dart';
import 'package:pulsehub/features/community/data/group_repository.dart';
import 'package:pulsehub/features/community/domain/group.dart';

/// In-memory [GroupRepository] double for widget/provider tests, so
/// nothing in the test suite ever touches a real Supabase project.
class FakeGroupRepository implements GroupRepository {
  List<Group> groups = [];

  Result<List<Group>>? getGroupsResult;
  Result<void>? createGroupResult;
  Result<void>? joinGroupResult;
  Result<void>? leaveGroupResult;

  int createGroupCallCount = 0;
  int joinGroupCallCount = 0;
  int leaveGroupCallCount = 0;

  @override
  Future<Result<List<Group>>> getGroups() async {
    return getGroupsResult ?? Result.success(groups);
  }

  @override
  Future<Result<void>> createGroup({
    required String name,
    String? description,
  }) async {
    createGroupCallCount++;
    return createGroupResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> joinGroup(String groupId) async {
    joinGroupCallCount++;
    return joinGroupResult ?? const Result.success(null);
  }

  @override
  Future<Result<void>> leaveGroup(String groupId) async {
    leaveGroupCallCount++;
    return leaveGroupResult ?? const Result.success(null);
  }
}
