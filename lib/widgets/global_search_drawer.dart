import 'package:flutter/material.dart';
import '../models/message.dart';
import '../database/database_helper.dart';

class SearchResult {
  final Message message;
  final String snippet;
  final int matchCount;

  SearchResult({
    required this.message,
    required this.snippet,
    required this.matchCount,
  });
}

class GlobalSearchDrawer extends StatefulWidget {
  final List<Message> messages;
  final Function(Message) onMessageSelected;
  final bool useDummyData;

  const GlobalSearchDrawer({
    super.key,
    required this.messages,
    required this.onMessageSelected,
    required this.useDummyData,
  });

  @override
  State<GlobalSearchDrawer> createState() => _GlobalSearchDrawerState();
}

class _GlobalSearchDrawerState extends State<GlobalSearchDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;

  // Normalizar texto removiendo acentos y convirtiendo a minúsculas
  String _normalize(String text) {
    const withAccents = 'áéíóúÁÉÍÓÚñÑ';
    const withoutAccents = 'aeiouAEIOUnN';
    String normalized = text.toLowerCase();

    for (int i = 0; i < withAccents.length; i++) {
      normalized = normalized.replaceAll(withAccents[i], withoutAccents[i]);
    }

    return normalized;
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      if (widget.useDummyData) {
        // Búsqueda en memoria para datos dummy
        _performDummySearch(query);
      } else {
        // Búsqueda en base de datos con FTS5
        await _performDatabaseSearch(query);
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en búsqueda: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _performDummySearch(String query) {
    final normalizedQuery = _normalize(query.trim());
    final results = <SearchResult>[];

    for (final message in widget.messages) {
      final normalizedContent = _normalize(message.content);
      final normalizedTitle = _normalize(message.title);

      // Buscar coincidencias
      final contentMatches = normalizedContent.contains(normalizedQuery);
      final titleMatches = normalizedTitle.contains(normalizedQuery);

      if (contentMatches || titleMatches) {
        // Contar coincidencias
        int matchCount = 0;
        int index = 0;
        while (
            (index = normalizedContent.indexOf(normalizedQuery, index)) != -1) {
          matchCount++;
          index += normalizedQuery.length;
        }

        // Extraer snippet
        String snippet = _extractSnippet(
          message.content,
          normalizedContent,
          normalizedQuery,
        );

        results.add(SearchResult(
          message: message,
          snippet: snippet,
          matchCount: matchCount,
        ));
      }
    }

    // Ordenar por número de coincidencias (mayor a menor)
    results.sort((a, b) => b.matchCount.compareTo(a.matchCount));

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _performDatabaseSearch(String query) async {
    final dbResults = await _dbHelper.searchFullText(query);
    
    final results = dbResults.map((dbResult) {
      return SearchResult(
        message: dbResult.message,
        snippet: dbResult.snippet,
        matchCount: dbResult.matchCount,
      );
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  String _extractSnippet(
      String originalContent, String normalizedContent, String query) {
    final index = normalizedContent.indexOf(query);
    if (index == -1) return '';

    const snippetRadius = 80;
    final start = (index - snippetRadius).clamp(0, originalContent.length);
    final end =
        (index + query.length + snippetRadius).clamp(0, originalContent.length);

    String snippet = originalContent.substring(start, end).trim();

    if (start > 0) snippet = '...$snippet';
    if (end < originalContent.length) snippet = '$snippet...';

    return snippet;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Búsqueda Global',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.useDummyData
                        ? 'Buscar en datos de prueba'
                        : 'Buscar en todos los mensajes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Frase exacta o palabras clave...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: _performSearch,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSearching
                        ? null
                        : () => _performSearch(_searchController.text),
                    icon: _isSearching
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? 'Buscando...' : 'Buscar'),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),

          // Resultados
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Resultados (${_searchResults.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (!widget.useDummyData) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 12,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'FTS5',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Ingresa una búsqueda'
                              : 'No se encontraron resultados',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: InkWell(
                          onTap: () => widget.onMessageSelected(result.message),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título
                                Text(
                                  result.message.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),

                                // Fecha y contador
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(result.message.date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${result.matchCount} ${result.matchCount == 1 ? 'coincidencia' : 'coincidencias'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Snippet
                                Text(
                                  result.snippet,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
