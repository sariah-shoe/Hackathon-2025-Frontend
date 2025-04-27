import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ironiq/config/app_config.dart';
import 'package:ironiq/core/theme/app_theme.dart';
import 'package:ironiq/core/theme/theme_manager.dart';
import 'package:ironiq/core/network/dio_client.dart';
import 'package:ironiq/core/storage/storage_service.dart';
import 'package:ironiq/data/datasources/remote/auth_remote_data_source.dart';
import 'package:ironiq/data/repositories/auth_repository_impl.dart';
import 'package:ironiq/presentation/blocs/auth/auth_bloc.dart';
import 'package:ironiq/presentation/blocs/auth/auth_event.dart';
import 'package:ironiq/presentation/screens/auth/welcome_screen.dart';

void main() async {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  AppConfig();
  await StorageService().init();

  runApp(const IronIQApp());
}

class IronIQApp extends StatelessWidget {
  const IronIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final dioClient = DioClient();
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      dioClient: dioClient,
    );
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    //debugDumpRenderTree();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: authRepository,
          )..add(const AuthCheckRequested()),
        ),
      ],
      child: ThemeManager(
        child: ScreenUtilInit(
          designSize: const Size(375, 812), // Standard iPhone X size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) => MaterialApp(
              title: 'IronIQ',
              theme: AppTheme.lightFromSeed(
                themeState.seedColor,
                contrastLevel: themeState.contrastLevel,
              ),
              darkTheme: AppTheme.darkFromSeed(
                themeState.seedColor,
                contrastLevel: themeState.contrastLevel,
              ),
              themeMode: themeState.mode,
              debugShowCheckedModeBanner: false,
              home: const WelcomeScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
