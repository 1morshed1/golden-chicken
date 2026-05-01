import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_chicken/core/network/api_exceptions.dart';
import 'package:golden_chicken/features/auth/domain/entities/user.dart';
import 'package:golden_chicken/features/auth/domain/usecases/login_usecase.dart';
import 'package:golden_chicken/features/auth/domain/usecases/logout_usecase.dart';
import 'package:golden_chicken/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:golden_chicken/features/auth/domain/usecases/register_usecase.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_event.dart';
import 'package:golden_chicken/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLogin;
  late MockRegisterUseCase mockRegister;
  late MockLogoutUseCase mockLogout;
  late MockRefreshTokenUseCase mockRefresh;

  const testUser = User(
    id: '1',
    fullName: 'Fahim',
    email: 'fahim@goldenchicken.ai',
  );

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockRegister = MockRegisterUseCase();
    mockLogout = MockLogoutUseCase();
    mockRefresh = MockRefreshTokenUseCase();
    bloc = AuthBloc(
      loginUseCase: mockLogin,
      registerUseCase: mockRegister,
      logoutUseCase: mockLogout,
      refreshTokenUseCase: mockRefresh,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is AuthInitial', () {
    expect(bloc.state, const AuthInitial());
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(
          () => mockLogin(email: any(named: 'email'), password: any(named: 'password')),
        ).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'fahim@goldenchicken.ai',
          password: 'pass123',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockLogin(email: any(named: 'email'), password: any(named: 'password')),
        ).thenAnswer((_) async => const Left(ServerFailure('Invalid credentials')));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(
          email: 'wrong@email.com',
          password: 'wrong',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated]',
      build: () {
        when(() => mockLogout()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated when token is valid',
      build: () {
        when(() => mockRefresh()).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when token is invalid',
      build: () {
        when(() => mockRefresh())
            .thenAnswer((_) async => const Left(AuthFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
