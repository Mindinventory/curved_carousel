import 'package:curved_carousel/curved_carousel.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curved Carousel Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CurvedCarouselDemo(),
    );
  }
}

class CurvedCarouselDemo extends StatefulWidget {
  const CurvedCarouselDemo({Key? key}) : super(key: key);

  @override
  State<CurvedCarouselDemo> createState() => _CurvedCarouselDemoState();
}

class _CurvedCarouselDemoState extends State<CurvedCarouselDemo> {

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Curved Carousel Demo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: CurvedCarousel(itemBuilder: (_ , i ) {
              return CircleAvatar(
                radius: 20,
                backgroundColor: Colors.primaries[i%Colors.primaries.length],
              );
            },
              itemCount: 10,
            ),
          )
        ],
      ),
    );
  }
}
