import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../movies/models/movie.dart';

class FeaturedMovieBanner extends StatelessWidget {
  const FeaturedMovieBanner({super.key, required this.movie});
  final Movie movie;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: .96, end: 1),
    duration: const Duration(milliseconds: 700),
    curve: Curves.easeOut,
    builder: (context, value, child) =>
        Transform.scale(scale: value, child: child),
    child: InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => context.push('/user/movie/${movie.id}'),
      child: Container(
        height: 238,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: .35),
          ),
          image: DecorationImage(
            image: NetworkImage(
              movie.backdropUrl.isNotEmpty
                  ? movie.backdropUrl
                  : movie.posterUrl,
            ),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xdd080a13)],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        child: Text(
                          'NỔI BẬT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff141322),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
