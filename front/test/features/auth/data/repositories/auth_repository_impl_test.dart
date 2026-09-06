import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel_v2/core/errors/app_exception.dart';
import 'package:sentinel_v2/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sentinel_v2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sentinel_v2/features/auth/domain/entities/app_user.dart';

AppUser _fakeUser({String id = 'user-1', String email = 'rider@sentinel.app'}) {
  return AppUser(id: id, email: email, displayName: 'Rider');
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  AppUser? userToReturn;
  Object? errorToThrow;
  bool signOutCalled = false;

  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => userToReturn;

  @override
  Stream<AppUser?> get onAuthStateChange => _controller.stream;

  void emit(AppUser? user) => _controller.add(user);

  @override
  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return userToReturn!;
  }

  @override
  Future<AppUser> signUpWithPassword({
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
    test('currentUser passes through the datasource user', () {
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

    test('signInWithPassword returns the user', () async {
      dataSource.userToReturn = _fakeUser();

      final user = await repository.signInWithPassword(
        email: 'rider@sentinel.app',
        password: 'super-secret',
      );

      expect(user.email, 'rider@sentinel.app');
    });

    test(
      'signInWithPassword translates an ApiException into a domain AuthException',
      () async {
        dataSource.errorToThrow = const ApiException(
          'invalid_credentials: Invalid login credentials',
          statusCode: 400,
        );

        await expectLater(
          () => repository.signInWithPassword(
            email: 'rider@sentinel.app',
            password: 'wrong',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.message,
              'message',
              'Correo o contraseña incorrectos.',
            ),
          ),
        );
      },
    );

    test('signUpWithPassword returns the user', () async {
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

    test('authStateChanges passes through the underlying stream', () async {
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
