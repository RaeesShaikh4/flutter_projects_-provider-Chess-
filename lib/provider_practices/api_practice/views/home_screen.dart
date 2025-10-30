import 'package:classic_chess/provider_practices/api_practice/repository/repository.dart';
import 'package:classic_chess/provider_practices/api_practice/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(postsRepository: PostsRepositoryImpl())..fetchPosts(),
      child: Scaffold(
        appBar: AppBar(title: const Text('API Practice'),),
        body: Consumer<HomeViewModel>(
          builder: (context1, viewModel, _) {
            if(viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(),);
            }

            if(viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage ?? 'Error Fetching data'),);
            }

            if(viewModel.posts.isEmpty) {
              return const Center(child: Text('No posts available'),);
            }

            return ListView.builder(itemBuilder: (context, index) {
              return ListTile(
                title: Text(viewModel.posts[index].title),
                subtitle: Text(viewModel.posts[index].body),
              );
            },);
          },

        )
      ),
      );
  }
}
