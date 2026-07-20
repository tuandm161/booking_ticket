import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_empty_view.dart';
import 'app_error_view.dart';
import 'app_loading_view.dart';

class AppAsyncValueWidget<T> extends StatelessWidget {
  const AppAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const AppLoadingView(),
    error: (error, _) =>
        AppErrorView(message: error.toString(), onRetry: onRetry),
    data: data,
  );
}

class AppEmptyListView extends StatelessWidget {
  const AppEmptyListView({super.key, this.title = 'Chưa có dữ liệu'});
  final String title;
  @override
  Widget build(BuildContext context) => AppEmptyView(title: title);
}
