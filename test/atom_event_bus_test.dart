import 'package:flutter_test/flutter_test.dart';

import 'package:atom_event_bus/atom_event_bus.dart';

void main() {
  Future<void> wait(int time) => Future.delayed(Duration(milliseconds: time));

  test('DebouncedEventListener should get triggered only after dobounce time',
      () async {
    final event = Event<int>("test event");
    int currentValue = 0;
    late EventRule<int> rule;

    rule = EventRule<int>(event, targets: [
      DebouncedEventListener(
        (payload) => currentValue = payload,
        duration: const Duration(milliseconds: 10),
      ),
    ]);

    EventBus.emit(event.createPayload(1));
    await wait(1);

    expect(currentValue, 0);

    EventBus.emit(event.createPayload(2));
    await wait(1);

    expect(currentValue, 0);

    EventBus.emit(event.createPayload(3));
    // will wait extra here to let the debounce listener to get called.
    await wait(20);

    expect(currentValue, 3);

    rule.cancel(); // canceling the rule subscription to prevent memory leak.
  });

  test('EventListener should get triggered for every event', () async {
    final event = Event<int>("test event");
    int currentValue = 0;
    late EventRule<int> rule;

    rule = EventRule<int>(event, targets: [
      EventListener((payload) => currentValue = payload),
    ]);

    EventBus.emit(event.createPayload(1));
    await wait(1); // The streams can take some time to propogate.

    expect(currentValue, 1);

    EventBus.emit(event.createPayload(2));
    await wait(1); // The streams can take some time to propogate.

    expect(currentValue, 2);

    EventBus.emit(event.createPayload(3));
    await wait(1); // The streams can take some time to propogate.

    expect(currentValue, 3);

    rule.cancel(); // canceling the rule subscription to prevent memory leak.
  });

  test('OneOffEventListener should get triggered only once', () async {
    final event = Event<int>("test event");
    int currentValue = 0;
    late EventRule<int> rule;

    rule = EventRule<int>(event, targets: [
      OneOffEventListener((payload) => currentValue = payload),
    ]);

    EventBus.emit(event.createPayload(1));
    await wait(1); // The streams can take some time to propogate.

    expect(currentValue, 1);

    EventBus.emit(event.createPayload(2));
    await wait(1); // The streams can take some time to propogate.

    expect(currentValue, 1);

    EventBus.emit(event.createPayload(3));
    await wait(1); // The streams can take some time to propogate.

    expect(currentValue, 1);

    rule.cancel(); // canceling the rule subscription to prevent memory leak.
  });
}
