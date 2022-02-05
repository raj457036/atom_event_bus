library atom_event_bus;

import 'dart:async';

import 'package:flutter/material.dart';

typedef EventCallback<T> = void Function(T payload);

class _EventPayload<T> {
  /// Event name which is carrying this payload
  final String name;
  final T value;

  /// Actual payload to [EventBus]
  ///
  /// To create a payload use [Event]'s method `createPayload`
  ///
  /// Example:
  ///
  /// ```dart
  ///
  /// final event = Event<String>("SignInEvent");
  ///
  /// // creating payload from [Event]
  /// final payload = event.createPayload("A String Payload.");
  ///
  /// // emitting the payload in event bus
  /// EventBus.emit(payload);
  ///
  ///
  /// ```
  _EventPayload(this.name, this.value);
}

class Event<T> {
  /// Name of the event
  final String name;

  /// Event blueprint for [EventRule]
  ///
  /// Example usage with [EventRule]
  ///
  /// ```dart
  /// final event1 = Event<int>("int");
  ///
  /// EventRule<int>(event1, targets: [
  ///   EventListener(
  ///     (payload) {
  ///       print("integer event: $payload");
  ///     },
  ///   ),
  /// ]);
  ///
  ///
  /// ....
  ///
  /// // Release Event
  /// EventBus.emit(event1.createPayload(100))
  ///
  /// // prints "integer event: 100"
  /// ```
  Event(this.name);

  /// creates a payload instance for event bus.
  ///
  /// See also:
  ///
  /// - [_EventPayload] : Payload for the [EventBus]
  ///
  /// Example:
  ///
  /// ```dart
  ///
  /// final event = Event<String>("SignInEvent");
  ///
  /// // creating payload from [Event]
  /// final payload = event.createPayload("A String Payload.");
  ///
  /// // emitting the payload in event bus
  /// EventBus.emit(payload);
  ///
  ///
  /// ```
  _EventPayload createPayload(T payload) => _EventPayload(name, payload);
}

class EventListener<T> {
  final EventCallback<T> _onEvent;

  /// Used by [EventRule] for triggering [onEvent] callback
  ///
  ///
  /// Example
  ///
  /// ```dart
  /// final event1 = Event<int>("int");
  ///
  /// EventRule<int>(event1, targets: [
  ///
  ///   // On Receiving `event1` call `onEvent`
  ///   // with `payload` of type [int]
  ///   EventListener(
  ///     (payload) {
  ///       print("integer event: $payload");
  ///     },
  ///   ),
  /// ]);
  ///
  ///
  /// ....
  ///
  /// // Release Event
  /// EventBus.emit(event1.createPayload(100))
  ///
  /// // prints "integer event: 100"
  /// ```
  ///
  ///
  /// See Also:
  ///
  /// - [OneOffEventListener] : An EventListener which only calls its onEvent one time.
  /// - [DebouncedEventListener] : An EventListenr which delays its calls to prevent frequent calls.
  ///
  ///
  EventListener(EventCallback<T> onEvent) : _onEvent = onEvent;

  void call(T data) {
    _onEvent(data);
  }
}

class OneOffEventListener<T> extends EventListener<T> {
  int _timesCalled = 0;

  /// Used by [EventRule] for triggering [onEvent] callback.
  ///
  /// A type of [EventListener] which only calls its onEvent one time.
  ///
  ///
  /// Example
  ///
  /// ```dart
  /// final event1 = Event<int>("int");
  ///
  /// EventRule<int>(event1, targets: [
  ///
  ///   // On Receiving `event1` call `onEvent`
  ///   // with `payload` of type [int]
  ///   OneOffEventListener(
  ///     (payload) {
  ///       print("integer event: $payload");
  ///     },
  ///   ),
  /// ]);
  ///
  ///
  /// ....
  ///
  /// // Release Event
  /// EventBus.emit(event1.createPayload(100)) // prints "integer event: 100"
  /// EventBus.emit(event1.createPayload(100)) // nothing happens
  /// EventBus.emit(event1.createPayload(100)) // nothing happens
  ///
  ///
  /// ```
  ///
  /// See Also:
  ///
  /// - [EventListener] : An EventListener which calls its onEvent.
  /// - [DebouncedEventListener] : An EventListenr which delays its calls to prevent frequent calls.
  ///
  ///
  OneOffEventListener(EventCallback<T> onEvent) : super(onEvent);

  @override
  void call(T data) {
    if (_timesCalled > 0) return;
    super.call(data);
    _timesCalled++;
  }
}

class DebouncedEventListener<T> extends EventListener<T> {
  /// Debounce time
  final Duration duration;
  Timer? _timer;

  /// Used by [EventRule] for triggering [onEvent] callback.
  ///
  /// A type of [EventListener] which delays its calls to prevent frequent calls.
  ///
  ///
  /// Example
  ///
  /// ```dart
  /// final event1 = Event<int>("int");
  ///
  /// EventRule<int>(event1, targets: [
  ///
  ///   // On Receiving `event1` call `onEvent`
  ///   // with `payload` of type [int]
  ///   DebouncedEventListener(
  ///     (payload) {
  ///       print("integer event: $payload");
  ///     },
  ///     duration: const Duration(seconds: 3),
  ///   ),
  /// ]);
  ///
  ///
  /// ....
  ///
  /// // Release Event
  /// EventBus.emit(event1.createPayload(100)) // nothing happens
  /// EventBus.emit(event1.createPayload(200)) // nothing happens
  /// EventBus.emit(event1.createPayload(400)) // prints "integer event: 400" after 3 second
  ///
  ///
  /// ```
  ///
  /// See Also:
  ///
  /// - [EventListener] : An EventListener which calls its onEvent.
  /// - [OneOffEventListener] : An EventListener which only calls its onEvent one time.
  ///
  ///
  /// `duration` : debounce time default: 1 second
  DebouncedEventListener(
    EventCallback<T> onEvent, {
    this.duration = const Duration(seconds: 1),
  }) : super(onEvent);

  @override
  void call(T data) {
    _timer?.cancel();
    _timer = Timer(duration, () => super.call(data));
  }
}

/// A singleton [EventBus]
///
/// [EventBus]'s [Event] are subscribed by [EventRule] subscribe  to
/// call corresponding [EventListener]'s callbacks.
///
/// Example
///
/// ```dart
/// final event1 = Event<int>("int");
///
/// EventRule<int>(event1, targets: [
///
///   // On Receiving `event1` call `onEvent`
///   // with `payload` of type [int]
///   EventListener(
///     (payload) {
///       print("integer event: $payload");
///     },
///   ),
/// ]);
///
///
/// ....
///
/// // Release Event
/// EventBus.emit(event1.createPayload(100))
///
/// // prints "integer event: 100"
/// ```
///
///
/// See Also:
/// - [EventListener] : An EventListener which calls its onEvent.
/// - [OneOffEventListener] : An EventListener which only calls its onEvent one time.
/// - [DebouncedEventListener] : An EventListenr which delays its calls to prevent frequent calls.
/// - [EventRule] : An EventLoop Subscriber
///
class EventBus {
  late final StreamController<_EventPayload> _stream;

  EventBus._() : _stream = StreamController.broadcast();
  static final EventBus _instance = EventBus._();

  static void emit<T>(_EventPayload<T> event) =>
      _instance._stream.sink.add(event);
}

class EventRule<T> {
  /// An [Event] to which this [EventRule] is subscribed to.
  final Event<T> event;

  late StreamSubscription _subscription;

  /// An [EventBus] Subscriber
  ///
  /// [EventRule] subscribe to [EventBus]'s [Event] to
  /// call corresponding [EventListener]'s callbacks.
  ///
  /// Example
  ///
  /// ```dart
  /// final event1 = Event<int>("int");
  ///
  /// final rule = EventRule<int>(event1, targets: [
  ///
  ///   // On Receiving `event1` call `onEvent`
  ///   // with `payload` of type [int]
  ///   EventListener(
  ///     (payload) {
  ///       print("integer event: $payload");
  ///     },
  ///   ),
  /// ]);
  ///
  ///
  /// // NOTE: DO NOT FORGOT TO CANCEL THE SUBSCRIPTION
  /// dispose() {
  ///   rule.cancel();
  /// }
  ///
  /// ....
  ///
  /// // Release Event
  /// EventBus.emit(event1.createPayload(100))
  ///
  /// // prints "integer event: 100"
  /// ```
  ///
  ///
  /// See Also:
  /// - [EventListener] : An EventListener which calls its onEvent.
  /// - [OneOffEventListener] : An EventListener which only calls its onEvent one time.
  /// - [DebouncedEventListener] : An EventListenr which delays its calls to prevent frequent calls.
  /// - [EventRule] : An EventLoop Subscriber
  ///
  EventRule(
    this.event, {
    required List<EventListener<T>> targets,
  }) {
    final stream = EventBus._instance._stream.stream;

    _subscription = stream.listen(
      (_event) {
        if (_event.name == event.name && _event.value is T) {
          for (var listener in targets) {
            listener(_event.value as T);
          }
        }
      },
    );
  }

  /// To prevent memory leak, cancel the subscription
  /// once there is no need for this [EventRule]
  void cancel() {
    _subscription.cancel();
  }
}
