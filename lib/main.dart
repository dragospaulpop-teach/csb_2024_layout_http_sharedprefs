import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: const Text('Hello World!'),
          actions: const [
            Icon(Icons.search),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300,
                height: 200,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue[100],
                ),
                child: const HttpDemo(),
              ),
              const SizedBox(height: 10),
              Container(
                width: 300,
                height: 200,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue[100],
                ),
                child: const SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MultipleBoxes(),
                      SizedBox(height: 10),
                      Flexible(child: BottomSheetWidget()),
                      SizedBox(height: 10),
                      Flexible(child: MaterialBannerWidget()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: BottomSheet(
          onClosing: () {},
          builder: (context) => Container(
            height: 100,
            color: Colors.blue[100],
            child: const Center(child: Text('Persistent bottom sheet!')),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text('Drawer Header'),
              ),
              ListTile(title: const Text('Item 1'), onTap: () {}),
            ],
          ),
        ),
        floatingActionButton: const SnackbarTrigger(),
      ),
    );
  }
}

class SnackbarTrigger extends StatelessWidget {
  const SnackbarTrigger({
    super.key,
  });

  void triggerSnackBar(BuildContext context) {
    const snackBar = SnackBar(content: Text('Yay a SnackBar!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => triggerSnackBar(context),
      child: const Icon(Icons.add),
    );
  }
}

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            height: 100,
            color: Colors.blue[100],
            child: const Center(child: Text('Modal bottom sheet!')),
          ),
        );
      },
      child: const Text('Open modal bottom sheet!'),
    );
  }
}

class MaterialBannerWidget extends StatelessWidget {
  const MaterialBannerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: const Text('Material banner!'),
            actions: [
              TextButton(onPressed: () {}, child: const Text('Action 1')),
            ],
          ),
        );
      },
      child: const Text('Open material banner!'),
    );
  }
}

class MultipleBoxes extends StatefulWidget {
  const MultipleBoxes({super.key});

  @override
  State<MultipleBoxes> createState() => _MultipleBoxesState();
}

class _MultipleBoxesState extends State<MultipleBoxes> {
  int _count = 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final List<Widget> children = List.generate(
        _count,
        (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 20,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: Colors.blue[400],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Box $index',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      );

      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _count++;
              });
            },
            child: const Text('Add box'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _count--;
              });
            },
            child: const Text('Remove box'),
          ),
          Column(
            children: children,
          ),
        ],
      );
    });
  }
}

class HttpDemo extends StatefulWidget {
  const HttpDemo({super.key});

  @override
  State<HttpDemo> createState() => _HttpDemoState();
}

class _HttpDemoState extends State<HttpDemo> {
  int postId = 1;
  String? postTitle;
  late Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    readSharedPrefs();
  }

  Future<void> readSharedPrefs() async {
    int? storedPostId = (await _prefs).getInt('postId');
    if (storedPostId == null) {
      (await _prefs).setInt('postId', 1);
    }
    setState(() {
      postId = storedPostId ?? 1;
    });
    callApi();
  }

  Future<void> callApi() async {
    final response =
        await http.get(Uri.parse('https://dummyjson.com/posts/$postId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        postTitle = data['title'];
      });
    } else {
      setState(() {
        postTitle = 'Failed to fetch data';
      });
    }
  }

  Future<void> navigatePost(String direction) async {
    int nextPostId = direction == 'next' ? postId + 1 : postId - 1;
    await (await _prefs).setInt('postId', nextPostId);
    setState(() {
      postId = nextPostId;
    });
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              postTitle ?? 'No data',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => navigatePost("previous"),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(width: 10),
            Text(postId.toString()),
            const SizedBox(width: 10),
            Expanded(
              child: IconButton(
                onPressed: () => navigatePost('next'),
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
