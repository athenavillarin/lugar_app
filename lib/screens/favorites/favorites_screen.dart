import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isInitialized = false;
  bool _showDeleteButtons = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final provider = context.read<FavoritesProvider>();
    await provider.fetchFavorites();
    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'FAVOURITES',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              setState(() {
                _showDeleteButtons = !_showDeleteButtons;
              });
            },
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : favoritesProvider.favorites.isEmpty
          ? _buildEmptyState(theme)
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildLocationRow(theme),
                  ),
                  const SizedBox(height: 12),
                  ...favoritesProvider.favorites.map((fav) {
                    return FavoriteCard(
                      favorite: fav,
                      showDeleteButton: _showDeleteButtons,
                      onDelete: () async {
                        await favoritesProvider.deleteFavorite(fav.id);
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('YOUR LOCATION', style: TextStyle(fontSize: 11)),
                SizedBox(height: 4),
                Text(
                  'LOREM IPSUM',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Image.asset(
            'assets/icons/star.png',
            width: 56,
            height: 56,
            color: theme.hintColor,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'No favourites yet',
            style: TextStyle(fontSize: 16, color: theme.hintColor),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap the star on a route to save it here',
            style: TextStyle(color: theme.hintColor),
          ),
        ),
      ],
    );
  }
}

class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.favorite,
    required this.showDeleteButton,
    required this.onDelete,
  });

  final FavoriteRoute favorite;
  final bool showDeleteButton;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(favorite.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${favorite.durationMinutes} mins',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.directions_walk, size: 20),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.directions_bus, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'P ${favorite.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Discounted',
                                  style: TextStyle(
                                    color: theme.hintColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTimeline(theme),
                    ],
                  ),
                ),
              ),
              if (showDeleteButton)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 69,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/trash.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme) {
    final checkpoints = favorite.checkpoints;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: Row(
            children: List.generate(checkpoints.length * 2 - 1, (i) {
              if (i.isEven) {
                final idx = i ~/ 2;
                return Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: idx == 0
                            ? theme.colorScheme.primary
                            : theme.hintColor,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        checkpoints[idx],
                        style: TextStyle(fontSize: 11, color: theme.hintColor),
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Container(
                      height: 2,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                );
              }
            }),
          ),
        ),
      ],
    );
  }
}
