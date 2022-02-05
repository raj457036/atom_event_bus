import 'package:atom_event_bus/atom_event_bus.dart';
import 'package:flutter/material.dart';

import 'events.dart';

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
    signInRule.cancel();
    super.dispose();
  }
}
