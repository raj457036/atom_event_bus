<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Atom Event Bus

An Event Bus to decouple your code dependencies.

## Features

- A single event bus for an app instance.
- Subscribe to any event anywhere
- debounce and oneOff listeners
- uses dart stream

## Diagram

<img src="https://raw.githubusercontent.com/raj457036/atom_event_bus/master/atom_event_bus.jpg" height="500">

## Getting started

```yaml
  dependencies:
    flutter:
      sdk: flutter
    
    # other deps
    atom_event_bus:
```


## Usage

1. Create Events
2. Subscribe to Events by EventRule
3. Emit Event by EventBus.emit

## Example


```dart

// --------------------------- events.dart ---------------------------
final signInEvent = Event<bool>("SIGN_IN_EVENT");

// -------------------------- subscriber.dart -------------------------
class SignedInStatus extends StatefulWidget {
  const SignedInStatus({Key? key}) : super(key: key);

  @override
  _SignedInStatusState createState() => _SignedInStatusState();
}

class _SignedInStatusState extends State<SignedInStatus> {
  bool signedIn = false;
  late EventRule signInRule;

  @override
  void initState() {
    super.initState();

    signInRule = EventRule<bool>(signInEvent, targets: [
      EventListener(onSignInEvent),
    ]);
  }

  void onSignInEvent(bool status) {
    setState(() {
      signedIn = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        "Is Signed In? \n${signedIn ? 'Yes' : 'No'}",
        textAlign: TextAlign.center,
        style: theme.headline1,
      ),
    );
  }

  @override
  void dispose() {
    signInRule.cancel(); // cancelling the subscription
    super.dispose();
  }
}


// ----------------- emitter.dart -------------------
class ToggleSignInStatus extends StatelessWidget {
  const ToggleSignInStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        EventBus.emit(signInEvent.createPayload(true));
      },
      child: const Icon(Icons.replay_outlined),
    );
  }
}


// ------------- main.dart -------------
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATOM EVENT BUS',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'ATOM EVENT BUS'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: const SignedInStatus(), // <-- subscribe to Events
      floatingActionButton: const ToggleSignInStatus(), // <-- emit Events
    );
  }
}

```

## Listeners

- **EventListener** : normal event listener which get trigger for every event of corresponding event rule.
- **OneOffEventListener** : event listener which get triggered only once.
- **DebouncedEventListener** : event lister which prevent frequent events and only capture last event after a short delay.


## Additional information

https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern
