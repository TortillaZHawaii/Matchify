import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchify/data/auth/auth_service.dart';
import 'package:matchify/features/auth/auth_cubit.dart';
import 'package:mocktail/mocktail.dart';

class AuthServiceMock extends Mock implements AuthService {}

void main() {
  group('AuthCubit signed out', () {
    late AuthServiceMock authService;
    late AuthCubit authCubit;

    String email = 'example@email.com';
    String password = 'password123';

    setUp(() {
      authService = AuthServiceMock();
      when(() => authService.isSignedInStream)
          .thenAnswer((_) => Stream.value(false));
      when(() => authService.isSignedIn).thenReturn(false);
      authCubit = AuthCubit(authService: authService);
    });

    blocTest(
      'Correct sign in',
      build: () {
        when(() => authService.signInWithEmail(email, password)).thenAnswer(
          (_) => Future.value(SignInResult.success),
        );

        return authCubit;
      },
      act: (AuthCubit authCubit) async {
        await authCubit.signInWithEmail(email, password);
      },
      expect: () => [
        isA<SigningInState>(),
        isA<SignedInState>(),
      ],
    );

    blocTest(
      'Incorrect sign in',
      build: () {
        when(() => authService.signInWithEmail(email, password)).thenAnswer(
          (_) => Future.value(SignInResult.wrongPassword),
        );

        return authCubit;
      },
      act: (AuthCubit authCubit) async {
        await authCubit.signInWithEmail(email, password);
      },
      expect: () => [
        isA<SigningInState>(),
        isA<SignedOutState>(),
      ],
    );

    blocTest(
      'Sign out',
      build: () {
        when(() => authService.signOut()).thenAnswer(
          (_) => Future.value(),
        );

        return authCubit;
      },
      act: (AuthCubit authCubit) async {
        await authCubit.signOut();
      },
      // we expect nothing to happen since we are signed out already
      expect: () => [],
    );
  });

  group('AuthCubit signed in', () {
    late AuthServiceMock authService;
    late AuthCubit authCubit;

    String email = 'example@email.com';
    String password = 'password123';

    setUp(() {
      authService = AuthServiceMock();
      when(() => authService.isSignedInStream)
          .thenAnswer((_) => Stream.value(true));
      when(() => authService.isSignedIn).thenReturn(true);
      authCubit = AuthCubit(authService: authService);
    });

    blocTest(
      'Correct sign in',
      build: () {
        when(() => authService.signInWithEmail(email, password)).thenAnswer(
          (_) => Future.value(SignInResult.success),
        );

        return authCubit;
      },
      act: (AuthCubit authCubit) async {
        await authCubit.signInWithEmail(email, password);
      },
      expect: () => [
        isA<SigningInState>(),
        isA<SignedInState>(),
      ],
    );

    blocTest(
      'Incorrect sign in',
      build: () {
        when(() => authService.signInWithEmail(email, password)).thenAnswer(
          (_) => Future.value(SignInResult.wrongPassword),
        );

        return authCubit;
      },
      act: (AuthCubit authCubit) async {
        await authCubit.signInWithEmail(email, password);
      },
      expect: () => [
        isA<SigningInState>(),
        isA<SignedOutState>(),
      ],
    );

    blocTest(
      'Sign out',
      build: () {
        when(() => authService.signOut()).thenAnswer(
          (_) => Future.value(),
        );

        return authCubit;
      },
      act: (AuthCubit authCubit) async {
        await authCubit.signOut();
      },
      expect: () => [
        isA<SignedOutState>(),
      ],
    );
  });
}
