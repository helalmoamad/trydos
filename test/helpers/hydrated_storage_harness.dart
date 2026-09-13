import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Test ledger · wave 00 Harness · unit "Shared helpers" — the in-memory
/// `HydratedStorage`.
///
/// `HomeBloc`, `ChatBloc` and `StoryBloc` are all `HydratedBloc`s. A
/// `HydratedBloc` reads `HydratedBloc.storage` in its constructor, so without a
/// storage set no such bloc can be built at all — the constructor throws
/// `StorageNotFound`. The real `HydratedStorage.build()` writes a Hive box to
/// disk, which a unit test must not do: it is slow, it needs a path provider,
/// and one test would leak its state into the next.
///
/// This class keeps the same four calls in a plain `Map`, so a test can seed a
/// stored payload before the bloc is built and read back what the bloc wrote.
class InMemoryHydratedStorage implements Storage {
  InMemoryHydratedStorage([Map<String, dynamic>? seed])
      : _box = <String, dynamic>{...?seed};

  final Map<String, dynamic> _box;

  /// What is stored right now — for assertions, not for the bloc.
  Map<String, dynamic> get contents => Map<String, dynamic>.unmodifiable(_box);

  /// Counts `write` calls, so a test can prove a bloc persisted (or did not
  /// persist) a state change instead of only checking the final value.
  int writeCount = 0;

  @override
  dynamic read(String key) => _box[key];

  @override
  Future<void> write(String key, dynamic value) async {
    writeCount++;
    _box[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _box.remove(key);
  }

  @override
  Future<void> clear() async {
    _box.clear();
  }

  @override
  Future<void> close() async {
    // Nothing to release: the box is a plain map.
  }
}

/// Installs a fresh in-memory storage and returns it.
///
/// Call this in `setUp` before building any hydrated bloc. Pass [seed] to place
/// a payload — an old release's payload, for instance — where the bloc will
/// find it on construction.
InMemoryHydratedStorage useInMemoryHydratedStorage([
  Map<String, dynamic>? seed,
]) {
  final InMemoryHydratedStorage storage = InMemoryHydratedStorage(seed);
  HydratedBloc.storage = storage;
  return storage;
}

/// Removes the storage again, so a test that forgot to install one fails with
/// `StorageNotFound` instead of quietly reusing the previous test's box.
void clearHydratedStorage() {
  HydratedBloc.storage = null;
}
