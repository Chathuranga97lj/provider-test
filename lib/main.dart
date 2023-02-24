import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    );
  }
}

class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({required this.name, required this.isActive})
      : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;
  // isActive == other.isActive && name == other.name;
  @override
  // TODO: implement hashCode
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  // set immutable list storage
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  // public access - when something changed notify and add to list
  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  // reset list
  void reset() {
    _items.clear();
    notifyListeners();
  }
}

// Ui for Bread crumb widget
class BreadCrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;

  const BreadCrumbsWidget({Key? key, required this.breadCrumbs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map((breadCrumb) {
        return GestureDetector(
          onTap: () {},
          child: Text(breadCrumb.title,
              style: TextStyle(
                color: breadCrumb.isActive ? Colors.blue : Colors.black,
              )),
        );
      }).toList(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Porvider"),
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbsWidget(
                breadCrumbs: value.items,
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/new',
              );
            },
            child: const Text("Add new bread crumb"),
          ),
          TextButton(
            onPressed: () {
              // access provider
              // use <-read-> method for one way communication
              context.read<BreadCrumbProvider>().reset();
            },
            child: const Text("Reset"),
          )
        ],
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({Key? key}) : super(key: key);

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  // create text editing controller
  late final TextEditingController _controller;

  // instantiate text editing controller
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  // dispose
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Bread Crumb"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "Enter a new bread crumb"),
          ),
          TextButton(
              onPressed: () {
                final text = _controller.text;
                if (text.isNotEmpty) {
                  final breadCrumb = BreadCrumb(isActive: false, name: text);
                  context.read<BreadCrumbProvider>().add(breadCrumb);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Add"))
        ],
      ),
    );
  }
}
