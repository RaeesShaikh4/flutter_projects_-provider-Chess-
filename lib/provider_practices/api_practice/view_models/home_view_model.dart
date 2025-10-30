import 'package:classic_chess/provider_practices/api_practice/models/posts.dart';
import 'package:classic_chess/provider_practices/api_practice/repository/repository.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final PostsRepository postsRepository;
  HomeViewModel({required this.postsRepository});

  bool _isLoading = false;
  String? _errorMessage;
  List<Posts> _posts = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Posts> get posts => _posts;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await postsRepository.getPosts();
    result.fold((error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    }, (data) {
      _posts = data;
      _isLoading = false;
      notifyListeners();
    });
  }
}
