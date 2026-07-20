import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_async_value_widget.dart';
import '../../models/tmdb_movie_summary.dart';
import '../../providers/tmdb_search_provider.dart';
import '../widgets/tmdb_result_tile.dart';

class TmdbSearchScreen extends ConsumerStatefulWidget {
  const TmdbSearchScreen({super.key, required this.onSelected});
  final ValueChanged<TmdbMovieSummary> onSelected;
  @override
  ConsumerState<TmdbSearchScreen> createState() => _TmdbSearchScreenState();
}

class _TmdbSearchScreenState extends ConsumerState<TmdbSearchScreen> {
  final _query = TextEditingController();
  String _submitted = '';
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * 0.8,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _query,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Tìm phim trên TMDB',
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _submitted = _query.text.trim()),
                icon: const Icon(Icons.search),
              ),
            ),
            onSubmitted: (value) => setState(() => _submitted = value.trim()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _submitted.isEmpty
                ? const Center(child: Text('Nhập từ khóa để tìm kiếm.'))
                : AppAsyncValueWidget(
                    value: ref.watch(tmdbSearchProvider(_submitted)),
                    onRetry: () =>
                        ref.invalidate(tmdbSearchProvider(_submitted)),
                    data: (items) => items.isEmpty
                        ? const Center(child: Text('Không tìm thấy phim.'))
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (_, index) => TmdbResultTile(
                              movie: items[index],
                              onTap: () => widget.onSelected(items[index]),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    ),
  );
}
