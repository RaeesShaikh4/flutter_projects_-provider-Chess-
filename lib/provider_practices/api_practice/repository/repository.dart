import 'package:classic_chess/provider_practices/api_practice/models/posts.dart';
import 'package:classic_chess/provider_practices/api_practice/services/api_client.dart';
import 'package:fpdart/fpdart.dart';

abstract class PostsRepository {
  Future<Either<Exception, List<Posts>>> getPosts();
}

class PostsRepositoryImpl implements PostsRepository {
  final apiClient = ApiClient();

  @override
  Future<Either<Exception, List<Posts>>> getPosts() async {
    final response = await apiClient.get<List<Posts>>('/posts');
    return response;
  }
}
