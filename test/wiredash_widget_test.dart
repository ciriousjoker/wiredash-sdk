// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/options/wiredash_options_data.dart';
import 'package:wiredash/src/core/project_credential_validator.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

import 'util/invocation_catcher.dart';
import 'util/mock_api.dart';
import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Wiredash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      WiredashServices.debugServicesCreator = createMockServices;
      addTearDown(() => WiredashServices.debugServicesCreator = null);
    });

    testWidgets('widget can be created', (tester) async {
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'test',
          child: SizedBox(),
        ),
      );

      expect(find.byType(Wiredash), findsOneWidget);
    });

    testWidgets('ping is send, even when the Widget gets updated',
        (tester) async {
      final robot = WiredashTestRobot(tester);
      robot.setupMocks();
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'invalid-secret',
          // this widget never settles, allowing us to jump in the future
          child: CircularProgressIndicator(),
        ),
      );
      final api1 = robot.mockServices.mockApi;
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump();

      expect(api1.pingInvocations.count, 0);
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'correct-secret',
          child: CircularProgressIndicator(),
        ),
      );
      final api2 = robot.mockServices.mockApi;
      expect(api1, isNot(api2)); // was updated
      await tester.pump();
      await tester.pump();

      expect(api2.pingInvocations.count, 0);
      print("wait 5s");
      await tester.pump(const Duration(seconds: 5));
      expect(api1.pingInvocations.count, 0);
      // makes sure the job doesn't die after being updated
      expect(api2.pingInvocations.count, 1);
    });

    testWidgets('reading Wiredash simply works and sends pings again',
        (tester) async {
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'test',
          // this widget never settles, allowing us to jump in the future
          child: CircularProgressIndicator(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final robot = WiredashTestRobot(tester);
      final api1 = robot.mockServices.mockApi;
      expect(api1.pingInvocations.count, 0);
      await tester.pump(const Duration(seconds: 5));
      expect(api1.pingInvocations.count, 1);

      // wait a bit, so we don't run in cases where the ping is not sent because
      // it was triggered too recently
      await tester.pump(const Duration(days: 1));

      // remove wiredash
      expect(find.byType(Wiredash), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpSmart();

      // add it a second time
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          // new secret makes the api, thus the SyncEngine rebuild
          secret: 'new secret',
          child: SizedBox(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final api2 = robot.mockServices.mockApi;
      expect(api2.pingInvocations.count, 0);
      await tester.pump(const Duration(seconds: 5));
      expect(api2.pingInvocations.count, 1);
    });

    testWidgets('No custom metadata is submitted with ping()', (tester) async {
      final robot = WiredashTestRobot(tester);
      robot.setupMocks();
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'invalid-secret',
          // this widget never settles, allowing us to jump in the future
          child: CircularProgressIndicator(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump();

      robot.wiredashController.modifyMetaData(
        (metaData) => metaData
          ..userEmail = 'customUserEmail'
          ..userId = 'customUserId'
          ..custom = {'customKey': 'customValue'},
      );

      print("wait 5s");
      await tester.pump(const Duration(seconds: 5));
      final api = robot.mockServices.mockApi;
      expect(api.pingInvocations.count, 1);
      final body = api.pingInvocations.latest[0]! as PingRequestBody;
      // user is not able to inject any custom information into the ping
      final json = jsonEncode(body.toRequestJson());
      expect(json, isNot(contains('custom')));
    });

    testWidgets(
      'calls ProjectCredentialValidator.validate() initially',
      (tester) async {
        final _MockProjectCredentialValidator validator =
            _MockProjectCredentialValidator();

        WiredashServices.debugServicesCreator = () => createMockServices()
          ..inject<ProjectCredentialValidator>((_) => validator);
        addTearDown(() => WiredashServices.debugServicesCreator = null);

        await tester.pumpWidget(
          const Wiredash(
            projectId: 'my-project-id',
            secret: 'my-secret',
            child: SizedBox(),
          ),
        );

        validator.validateInvocations.verifyInvocationCount(1);
        final lastCall = validator.validateInvocations.latest;
        expect(lastCall['projectId'], 'my-project-id');
        expect(lastCall['secret'], 'my-secret');
      },
    );

    testWidgets('Do not lose state of app on open/close', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp(
        builder: (_) => const _FakeApp(),
      );
      expect(_FakeApp.initCount, 1);
      await robot.openWiredash();
      expect(_FakeApp.initCount, 1);
      await robot.closeWiredash();
      expect(_FakeApp.initCount, 1);
    });

    testWidgets('verify feedback options in show() overrides the options',
        (tester) async {
      const options = WiredashFeedbackOptions(
        email: EmailPrompt.hidden,
        screenshot: ScreenshotPrompt.hidden,
      );
      final robot = await WiredashTestRobot(tester).launchApp(
        feedbackOptions: const WiredashFeedbackOptions(
          email: EmailPrompt.optional,
          screenshot: ScreenshotPrompt.optional,
        ),
        builder: (context) {
          return Scaffold(
            body: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Wiredash.of(context).show(
                      options: options,
                    );
                  },
                  child: const Text('Feedback'),
                ),
              ],
            ),
          );
        },
        afterPump: () async {
          // The Localizations widget shows an empty Container while the
          // localizations are loaded (which is async)
          await tester.pumpSmart();
        },
      );

      await robot.openWiredash();
      expect(robot.services.wiredashModel.feedbackOptions, options);

      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();

      // Verify that screenshot and email are hidden
      expect(
        robot.services.feedbackModel.feedbackFlowStatus,
        FeedbackFlowStatus.submit,
      );
    });

    group('localization', () {
      testWidgets(
          'Wiredash on top of MaterialApp does not override existing Localizations',
          (tester) async {
        final robot = await WiredashTestRobot(tester).launchApp(
          appLocalizationsDelegates: const [
            _AppLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          builder: (context) {
            final _AppLocalizations l10n =
                Localizations.of(context, _AppLocalizations)!;
            return Scaffold(
              body: Column(
                children: [
                  Text(l10n.customAppString),
                  GestureDetector(
                    onTap: () {
                      Wiredash.of(context).show();
                    },
                    child: const Text('Feedback'),
                  ),
                ],
              ),
            );
          },
          afterPump: () async {
            // The Localizations widget shows an empty Container while the
            // localizations are loaded (which is async)
            await tester.pumpSmart();
          },
        );

        expect(find.text('custom app string'), findsOneWidget);

        await robot.openWiredash();

        expect(find.text('custom app string'), findsOneWidget);
      });

      testWidgets(
          'Wiredash below MaterialApp does not override existing Localizations',
          (tester) async {
        final robot = await WiredashTestRobot(tester).launchApp(
          appLocalizationsDelegates: const [
            _AppLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          builder: (context) {
            // Wrap screen with Wiredash, because that should work too
            return Wiredash(
              projectId: 'test',
              secret: 'test',
              options: WiredashOptionsData(
                locale: const Locale('test'),
                localizationDelegate: WiredashTestLocalizationDelegate(),
              ),
              child: Builder(
                builder: (context) {
                  // Access localization with context below
                  final _AppLocalizations l10n =
                      Localizations.of(context, _AppLocalizations)!;
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(l10n.customAppString),
                        GestureDetector(
                          onTap: () {
                            Wiredash.of(context).show();
                          },
                          child: const Text('Feedback'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          afterPump: () async {
            // The Localizations widget shows an empty Container while the
            // localizations are loaded (which is async)
            await tester.pumpSmart();
          },
        );

        expect(find.text('custom app string'), findsOneWidget);

        await robot.openWiredash();

        expect(find.text('custom app string'), findsOneWidget);
      });
    });

    testWidgets('Track telemetry', (tester) async {
      final robot = await WiredashTestRobot(tester).launchApp();
      await robot.openWiredash();
      final appStartCount = await robot.services.appTelemetry.appStartCount();
      expect(appStartCount, 1);
      final firstAppStart = await robot.services.appTelemetry.firstAppStart();
      expect(firstAppStart, isNotNull);
    });
  });

  group('Third party app', () {
    testWidgets('A test with Wiredash does no I/O', (tester) async {
      SharedPreferences.setMockInitialValues({});

      final api = MockWiredashApi();
      WiredashServices.debugServicesCreator = () {
        return WiredashServices.setup((services) {
          registerProdWiredashServices(services);
          // Don't do actual http calls
          services.inject<WiredashApi>((_) {
            // depend on the widget (secret/project)
            services.wiredashWidget;
            return api;
          });
        });
      };

      await tester.pumpWidget(
        const Wiredash(
          projectId: 'any',
          secret: 'thing',
          child: MaterialApp(),
        ),
      );

      await tester.pump(const Duration(minutes: 10));

      // No http calls
      expect(api.pingInvocations.count, 0);
      expect(api.sendFeedbackInvocations.count, 0);
      expect(api.uploadAttachmentInvocations.count, 0);
      expect(api.sendPsInvocations.count, 0);

      // not disk writes
      final data = await SharedPreferences.getInstance();
      expect(data.getKeys(), isEmpty);
    });
  });

  group('registry', () {
    testWidgets('cleanup removes inaccessible references', (tester) async {
      expect(WiredashRegistry.instance.referenceCount, 0);

      await tester.pumpWidget(
        const Wiredash(
          projectId: 'my-project-id',
          secret: 'my-secret',
          child: SizedBox(),
        ),
      );
      expect(WiredashRegistry.instance.referenceCount, 1);

      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          Wiredash(
            key: ValueKey(i),
            projectId: 'my-project-id-$i',
            secret: 'my-secret',
            child: const SizedBox(),
          ),
        );
        expect(WiredashRegistry.instance.referenceCount, 1);
      }

      await tester.pumpWidget(const SizedBox());
      expect(WiredashRegistry.instance.referenceCount, 0);
    });

    test('singleton', () {
      final r1 = WiredashRegistry.instance;
      final r2 = WiredashRegistry.instance;
      expect(identical(r1, r2), isTrue);
    });

    testWidgets('add existing item throws', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp();

      final registry = WiredashRegistry.instance;
      final element =
          tester.firstElement(find.byWidget(robot.widget)) as StatefulElement;
      expect(
        () => registry.register(element.state as WiredashState),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('is already registered'),
          ),
        ),
      );
    });

    testWidgets('add item', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp();

      final registry = WiredashRegistry.instance;
      expect(registry.allWidgets, hasLength(1));
      expect(registry.referenceCount, 1);
    });

    test('zero items', () {
      // by default, the registry is empty.
      // and the state added in the previous test is not present anymore
      expect(WiredashRegistry.instance.allWidgets, isEmpty);
    });
  });
}

class _MockProjectCredentialValidator extends Fake
    implements ProjectCredentialValidator {
  final MethodInvocationCatcher validateInvocations =
      MethodInvocationCatcher('validate');

  @override
  Future<void> validate({
    required String projectId,
    required String secret,
  }) async {
    return validateInvocations.addAsyncMethodCall(
      namedArgs: {
        'projectId': projectId,
        'secret': secret,
      },
    )?.future;
  }
}

class _FakeApp extends StatefulWidget {
  const _FakeApp();

  @override
  State<_FakeApp> createState() => _FakeAppState();

  static int initCount = 0;
}

class _FakeAppState extends State<_FakeApp> {
  @override
  void initState() {
    _FakeApp.initCount++;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Wiredash.of(context).show();
            },
            child: const Text('Feedback'),
          ),
        ],
      ),
    );
  }
}

class _AppLocalizations {
  final Locale locale;

  const _AppLocalizations({required this.locale});

  String get customAppString => 'custom app string';

  static const LocalizationsDelegate<_AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<_AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<_AppLocalizations> load(Locale locale) async {
    return _AppLocalizations(locale: locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
