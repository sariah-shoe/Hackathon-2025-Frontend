import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Theme state
class ThemeState {
  final ThemeMode mode;
  final Color seedColor;
  final double contrastLevel;

  const ThemeState({
    required this.mode,
    required this.seedColor,
    this.contrastLevel = 0.0,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    Color? seedColor,
    double? contrastLevel,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
      contrastLevel: contrastLevel ?? this.contrastLevel,
    );
  }
}

/// Theme events
abstract class ThemeEvent {}

/// Change theme mode event
class ChangeThemeModeEvent extends ThemeEvent {
  final ThemeMode mode;
  ChangeThemeModeEvent(this.mode);
}

/// Change seed color event
class ChangeSeedColorEvent extends ThemeEvent {
  final Color seedColor;
  ChangeSeedColorEvent(this.seedColor);
}

/// Change contrast level event
class ChangeContrastLevelEvent extends ThemeEvent {
  final double contrastLevel;
  ChangeContrastLevelEvent(this.contrastLevel);
}

/// Theme bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(ThemeState(
          mode: ThemeMode.dark,
//          seedColor: const Color(0xFF6750A4),
          seedColor: const Color(0xFF673ab7),
        )) {
    on<ChangeThemeModeEvent>(_onChangeThemeMode);
    on<ChangeSeedColorEvent>(_onChangeSeedColor);
    on<ChangeContrastLevelEvent>(_onChangeContrastLevel);
  }

  void _onChangeThemeMode(
      ChangeThemeModeEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(mode: event.mode));
  }

  void _onChangeSeedColor(
      ChangeSeedColorEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(seedColor: event.seedColor));
  }

  void _onChangeContrastLevel(
      ChangeContrastLevelEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(contrastLevel: event.contrastLevel));
  }
}

/// Theme manager widget
class ThemeManager extends StatelessWidget {
  final Widget child;

  const ThemeManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return child;
        },
      ),
    );
  }

  /// Get current theme state
  static ThemeState getThemeState(BuildContext context) {
    return context.read<ThemeBloc>().state;
  }

  /// Change theme mode
  static void changeThemeMode(BuildContext context, ThemeMode mode) {
    context.read<ThemeBloc>().add(ChangeThemeModeEvent(mode));
  }

  /// Change seed color
  static void changeSeedColor(BuildContext context, Color color) {
    context.read<ThemeBloc>().add(ChangeSeedColorEvent(color));
  }

  /// Change contrast level
  static void changeContrastLevel(BuildContext context, double level) {
    context.read<ThemeBloc>().add(ChangeContrastLevelEvent(level));
  }

  /// Toggle between light and dark theme
  static void toggleTheme(BuildContext context) {
    final currentMode = getThemeState(context).mode;
    final newMode =
        currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    changeThemeMode(context, newMode);
  }
}
