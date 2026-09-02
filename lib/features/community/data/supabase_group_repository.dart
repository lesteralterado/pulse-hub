import '../../../core/errors/result.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/group.dart';
import 'group_repository.dart';
import 'supabase_post_repository.dart' show SupabasePostRepository;

class SupabaseGroupRepository implements GroupRepository {
  String get _requireUserId {
    final id = SupabaseService.client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('SupabaseGroupRepository used while signed out');
    }
    return id;
  }

  @override
  Future<Result<List<Group>>> getGroups() async {
    try {
      final rows = await SupabaseService.client
          .from('group_summary')
          .select()
          .order('name', ascending: true);
      return Result.success(rows.map(Group.fromMap).toList());
    } catch (error) {
      return Result.failure(SupabasePostRepository.mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> createGroup({
    required String name,
    String? description,
  }) async {
    try {
      await SupabaseService.client.from('groups').insert({
        'name': name,
        'description': description,
        'created_by': _requireUserId,
      });
      return const Result.success(null);
    } catch (error) {
      return Result.failure(SupabasePostRepository.mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> joinGroup(String groupId) async {
    try {
      final userId = _requireUserId;
      await SupabaseService.client.from('group_members').upsert(
        {'group_id': groupId, 'user_id': userId, 'role': 'member'},
        onConflict: 'group_id,user_id',
        ignoreDuplicates: true,
      );
      return const Result.success(null);
    } catch (error) {
      return Result.failure(SupabasePostRepository.mapCommunityError(error));
    }
  }

  @override
  Future<Result<void>> leaveGroup(String groupId) async {
    try {
      final userId = _requireUserId;
      await SupabaseService.client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return const Result.success(null);
    } catch (error) {
      return Result.failure(SupabasePostRepository.mapCommunityError(error));
    }
  }
}
