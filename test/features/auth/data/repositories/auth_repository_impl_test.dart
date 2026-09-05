import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart' as core;
import 'package:sentinel_v2/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sentinel_v2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

supabase.User _fakeUser({
  String id = 'user-1',
  String email = 'rider@sentinel.app',
}) {
  return supabase.User(
    id: id,
    appMetadata: const {},
    userMetadata: const {'display_name': 'Rider'},
    aud: 'authenticated',
    email: email,
    createdAt: DateTime(2026).toIso8601String(),
  );
}

supabase.AuthState _fakeAuthState(supabase.User? user) {
  return supabase.AuthState(
    user == null
        ? supabase.AuthChangeEvent.signedOut
        : supabase.AuthChangeEvent.signedIn,
    user == null
        ? null
        : supabase.Session(
            accessToken: 'token',
            tokenType: 'bearer',
            user: user,
          ),
  );
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  supabase.User? userToReturn;
  Object? errorToThrow;
  bool signOutCalled = false;

  final _controller = StreamController<supabase.AuthState>.broadcast();

  @override
  supabase.User? get currentUser => userToReturn;

  @override
  Stream<supabase.AuthState> get onAuthStateChange => _controller.stream;

  void emit(supabase.User? user) => _controller.add(_fakeAuthState(user));

  @override
  Future<supabase.User> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return userToReturn!;
  }

  @override
  Future<supabase.User> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return userToReturn!;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

void main() {
  late _FakeAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  group('AuthRepositoryImpl', () {
    test('currentUser maps the datasource user to an AppUser', () {
      dataSource.userToReturn = _fakeUser();

      final user = repository.currentUser;

      expect(user?.id, 'user-1');
      expect(user?.email, 'rider@sentinel.app');
      expect(user?.displayName, 'Rider');
    });

    test('currentUser is null when there is no session', () {
      dataSource.userToReturn = null;

      expect(repository.currentUser, isNull);
    });

    test('signInWithPassword returns the mapped AppUser', () async {
      dataSource.userToReturn = _fakeUser();

      final user = await repository.signInWithPassword(
        email: 'rider@sentinel.app',
        password: 'super-secret',
      );

      expect(user.email, 'rider@sentinel.app');
    });

    test('signInWithPassword translates a Supabase AuthException into a domain AuthException', () async {
      dataSource.errorToThrow = const supabase.AuthApiException(
        'Invalid login credentials',
        code: 'invalid_credentials',
      );

      await expectLater(
        () => repository.signInWithPassword(
          email: 'rider@sentinel.app',
          password: 'wrong',
        ),
        throwsA(isA<core.AuthException>()),
      );
    });

    test('signUpWithPassword returns the mapped AppUser', () async {
      dataSource.userToReturn = _fakeUser();

      final user = await repository.signUpWithPassword(
        email: 'rider@sentinel.app',
        password: 'super-secret',
        displayName: 'Rider',
      );

      expect(user.email, 'rider@sentinel.app');
    });

    test('signOut delegates to the datasource', () async {
      await repository.signOut();

      expect(dataSource.signOutCalled, isTrue);
    });

    test('authStateChanges maps the underlying stream', () async {
      final events = <String?>[];
      final subscription = repository.authStateChanges.listen(
        (user) => events.add(user?.email),
      );

      dataSource.emit(_fakeUser());
      dataSource.emit(null);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(events, ['rider@sentinel.app', null]);
    });
  });
}
