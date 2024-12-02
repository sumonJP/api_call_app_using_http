import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Public API Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('JSONPlaceholder API')),
        backgroundColor: Colors.deepPurple[800],
        body: PostsList(),
      ),
    );
  }
}

class PostsList extends StatefulWidget {
  @override
  _PostsListState createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  List<dynamic> posts = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  // Fetch data from API
  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  // Retry fetching data
  void retryFetch() {
    setState(() {
      isError = false;
    });
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator() // Show a loader while data is loading
          : isError
              ? ErrorScreen(
                  onRetry: retryFetch) // Show error screen if there's an error
              : RefreshableListView(
                  posts: posts,
                  onRefresh: fetchPosts), // Display data in ListView
    );
  }
}

// Custom widget for displaying the posts list
class RefreshableListView extends StatelessWidget {
  final List<dynamic> posts;
  final Future<void> Function() onRefresh;

  RefreshableListView({required this.posts, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                post['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(post['body']),
            ),
          );
        },
      ),
    );
  }
}

// Custom widget to show an error screen with retry option
class ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  ErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error fetching posts!',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
