import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// JSON type aliases
typedef Json = Map<String, dynamic>;
typedef JsonList = List<Json>;

/// Common callback types
typedef VoidCallback = void Function();
typedef ErrorCallback = void Function(String message);
typedef LoadingCallback = void Function(bool isLoading);
typedef DataCallback<T> = void Function(T data);

/// Result types using Either from dartz
typedef ResultCallback<T> = void Function(Either<Failure, T> result);
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = ResultFuture<void>;

/// Validation types
typedef ValidationCallback = String? Function(String? value);
typedef AsyncValidationCallback = Future<String?> Function(String? value);

/// Builder types
typedef WidgetCallback = Widget Function();
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef AsyncItemBuilder<T> = Widget Function(
    BuildContext context, AsyncSnapshot<T> snapshot);

/// Data transformation
typedef DataTransformer<T, R> = R Function(T data);
typedef AsyncDataTransformer<T, R> = Future<R> Function(T data);

/// Event handling
typedef EventCallback<T> = void Function(T event);
typedef AsyncEventCallback<T> = Future<void> Function(T event);

/// Resource management
typedef ResourceCleanup = Future<void> Function();
typedef ConnectionStateCallback = void Function(bool connected);
