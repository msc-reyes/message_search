import 'package:flutter/material.dart';
import '../models/message.dart';
import '../database/database_helper.dart';

class MatchOccurrence {
  final String snippet;
  final int position;

  MatchOccurrence({
    required this.snippet,
    required this.position,
  });
}

class SearchResult {
  final Message message;
  final List<MatchOccurrence> occurrences;
  final int matchCount;

  SearchResult({
    required this.message,
    required this.occurrences,
    required this.matchCount,
  });
}

class GlobalSearchDrawer extends StatefulWidget {
  final List<Message> messages;
  final Function(Message message, {int? scrollToPosition, String? searchQuery}) onMessageSelected;
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
  final Set<int> _expandedResults = {};
  bool _isSearching = false;
  String _currentSearchQuery = '';

  // Normalizar texto removiendo acentos y convirtiendo a minúsculas
  String _normalize(String text) {
    const withAccents = 'áéíóúÁÉÍÓÚñÑüÜ';
    const withoutAccents = 'aeiouAEIOUnNuU';
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
        _expandedResults.clear();
        _currentSearchQuery = '';
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentSearchQuery = query.trim();
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
        _expandedResults.clear();
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
      final occurrences = <MatchOccurrence>[];

      // Encontrar todas las coincidencias con índices correctos en el original
      final matches = _findAllMatches(message.content, normalizedQuery);
      
      for (final matchIndex in matches) {
        final snippet = _extractSnippet(
          message.content,
          normalizedQuery,
          matchIndex,
        );
        
        occurrences.add(MatchOccurrence(
          snippet: snippet,
          position: matchIndex,
        ));
      }

      if (occurrences.isNotEmpty) {
        results.add(SearchResult(
          message: message,
          occurrences: occurrences,
          matchCount: occurrences.length,
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

  // Encuentra todas las posiciones donde aparece el query normalizado en el contenido original
  List<int> _findAllMatches(String originalContent, String normalizedQuery) {
    final matches = <int>[];
    final queryLength = normalizedQuery.length;
    
    for (int i = 0; i <= originalContent.length - queryLength; i++) {
      final substring = originalContent.substring(i, i + queryLength);
      if (_normalize(substring) == normalizedQuery) {
        matches.add(i);
        i += queryLength - 1; // Saltar a después de esta coincidencia
      }
    }
    
    return matches;
  }

  Future<void> _performDatabaseSearch(String query) async {
    final dbResults = await _dbHelper.searchFullText(query);
    final results = <SearchResult>[];
    final normalizedQuery = _normalize(query.trim());

    for (final dbResult in dbResults) {
      final occurrences = <MatchOccurrence>[];

      // Encontrar todas las coincidencias con índices correctos
      final matches = _findAllMatches(dbResult.message.content, normalizedQuery);
      
      for (final matchIndex in matches) {
        final snippet = _extractSnippet(
          dbResult.message.content,
          normalizedQuery,
          matchIndex,
        );
        
        occurrences.add(MatchOccurrence(
          snippet: snippet,
          position: matchIndex,
        ));
      }

      if (occurrences.isNotEmpty) {
        results.add(SearchResult(
          message: dbResult.message,
          occurrences: occurrences,
          matchCount: occurrences.length,
        ));
      }
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  String _extractSnippet(
      String originalContent, 
      String query,
      int matchIndex) {
    
    // Configuración del snippet
    const contextChars = 100; // Caracteres de contexto antes/después
    
    // Calcular posiciones de inicio y fin
    int start = (matchIndex - contextChars).clamp(0, originalContent.length);
    int end = (matchIndex + query.length + contextChars).clamp(0, originalContent.length);
    
    // Intentar ajustar el inicio a un límite de palabra (espacio/salto de línea)
    // para mejor legibilidad, pero solo si no estamos muy lejos
    if (start > 0) {
      for (int i = start; i < start + 20 && i < matchIndex; i++) {
        if (originalContent[i] == ' ' || originalContent[i] == '\n') {
          start = i + 1;
          break;
        }
      }
    }
    
    // Intentar ajustar el final a un límite de palabra
    if (end < originalContent.length) {
      for (int i = end; i > end - 20 && i > matchIndex + query.length; i--) {
        if (originalContent[i] == ' ' || originalContent[i] == '\n') {
          end = i;
          break;
        }
      }
    }
    
    // Extraer snippet
    String snippet = originalContent.substring(start, end).trim();
    
    // Reemplazar múltiples espacios/saltos de línea con un solo espacio
    snippet = snippet.replaceAll(RegExp(r'\s+'), ' ');

    if (start > 0) snippet = '...$snippet';
    if (end < originalContent.length) snippet = '$snippet...';

    return snippet;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedResults.contains(index)) {
        _expandedResults.remove(index);
      } else {
        _expandedResults.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalMatches = _searchResults.fold<int>(
      0, 
      (sum, result) => sum + result.matchCount
    );

    // Ancho del drawer: 40% más ancho que el default
    final drawerWidth = MediaQuery.of(context).size.width * 0.45;

    return Drawer(
      width: drawerWidth,
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu búsqueda...',
                    hintStyle: const TextStyle(fontSize: 16),
                    prefixIcon: const Icon(Icons.search, size: 24),
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

          // Resultados header
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      '$totalMatches coincidencia${totalMatches != 1 ? 's' : ''} en ${_searchResults.length} mensaje${_searchResults.length != 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                          size: 80,
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
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                      final isExpanded = _expandedResults.contains(index);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Column(
                          children: [
                            // Header del mensaje (siempre visible)
                            InkWell(
                              onTap: () => _toggleExpanded(index),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            result.message.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
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
                                              .bodyMedium
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
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Lista de coincidencias (expandible)
                            if (isExpanded)
                              Column(
                                children: [
                                  Divider(
                                    height: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.3),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: result.occurrences.length,
                                    itemBuilder: (context, occIndex) {
                                      final occurrence = result.occurrences[occIndex];
                                      
                                      return InkWell(
                                        onTap: () {
                                          widget.onMessageSelected(
                                            result.message,
                                            scrollToPosition: occurrence.position,
                                            searchQuery: _currentSearchQuery,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: occIndex < result.occurrences.length - 1
                                                  ? BorderSide(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outline
                                                          .withOpacity(0.1),
                                                    )
                                                  : BorderSide.none,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  right: 8,
                                                  top: 2,
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${occIndex + 1}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  occurrence.snippet,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
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
