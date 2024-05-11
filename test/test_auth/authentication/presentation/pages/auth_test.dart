import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:trydos/features/authentication/data/models/create_user_response_model.dart';
import 'package:trydos/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:trydos/service/service_provider.dart';

import '../../../helpers/test_helper.mocks.dart';

class MockWeatherBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    HttpOverrides.global = null;
  });

  Widget builds() {
    return ServiceProvider(child: Builder(builder: (context) {
      return const Scaffold();
    }));
  }

  final testcreatusermodel = CreateUserResponseModel(
      mobilePhone: "0855566666666",
      id: 12,
      createdAt: DateTime.tryParse("2200-21-22"),
      name: "helal",
      updatedAt: DateTime.now(),
      username: "ali ,pha,a,");

  testWidgets(
    'text field should trigger state to change from empty to loading',
    (widgetTester) async {
      //arrange
      when(() => mockAuthBloc.state)
          .thenReturn(const AuthState(createUserStatus: CreateUserStatus.init));

      //act
      await widgetTester.pumpWidget(builds());
      var textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await widgetTester.enterText(textField, 'New York');
      await widgetTester.pump();
      expect(find.text('New York'), findsOneWidget);
    },
  );

  /* testWidgets(
    'should show progress indicator when state is loading',
    (widgetTester) async {
      //arrange
      when(()=> mockWeatherBloc.state).thenReturn(WeatherLoading());

      //act
      await widgetTester.pumpWidget(_makeTestableWidget(const WeatherPage()));
      
      //assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }, 
  );


  testWidgets(
    'should show widget contain weather data when state is weather loaded',
    (widgetTester) async {
      //arrange
      when(()=> mockWeatherBloc.state).thenReturn(const WeatherLoaded(testWeather));

      //act
      await widgetTester.pumpWidget(_makeTestableWidget(const WeatherPage()));
      
      //assert
      expect(find.byKey(const Key('weather_data')), findsOneWidget);
    }, 
  );*/
}
