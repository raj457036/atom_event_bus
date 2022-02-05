import 'package:atom_event_bus/atom_event_bus.dart';
import 'package:example/events.dart';
import 'package:flutter/material.dart';

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
