import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../widgets/message_list_drawer.dart';
import '../widgets/global_search_drawer.dart';
import '../widgets/bible_viewer.dart';
import '../database/database_helper.dart';
import 'import_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ScrollController _messageScrollController = ScrollController();
  
  List<Message> _messages = [];
  Message? _currentMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  bool _useDummyData = false;

  // Navegación entre resultados
  int _currentMatchIndex = 0;
  List<int> _matchPositions = [];
  final GlobalKey _contentKey = GlobalKey();

  // Configuración de zoom de fuente
  double _fontSizeMultiplier = 1.0;
  static const double _baseFontSize = 18.0;
  static const double _minMultiplier = 0.7;
  static const double _maxMultiplier = 2.0;
  static const double _step = 0.1;

  @override
  void initState() {
    super.initState();
    _loadFontPreference();
    _loadMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_messageScrollController.hasClients) {
      _messageScrollController.jumpTo(0);
    }
  }

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

  int _countMatches(String text, String query) {
    if (query.isEmpty) return 0;
    
    final normalizedText = _normalize(text);
    final normalizedQuery = _normalize(query);
    int count = 0;
    int index = 0;
    
    _matchPositions.clear();
    
    while ((index = normalizedText.indexOf(normalizedQuery, index)) != -1) {
      _matchPositions.add(index);
      count++;
      index += query.length;
    }
    
    return count;
  }

  void _navigateToNextMatch() {
    if (_matchPositions.isEmpty) return;
    
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matchPositions.length;
    });
    
    _scrollToMatch();
  }

  void _navigateToPreviousMatch() {
    if (_matchPositions.isEmpty) return;
    
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _matchPositions.length) % _matchPositions.length;
    });
    
    _scrollToMatch();
  }

  void _scrollToMatch() {
    if (_messageScrollController.hasClients && _matchPositions.isNotEmpty) {
      // Estimación de posición de scroll basada en el índice del carácter
      final totalChars = _currentMessage?.content.length ?? 1;
      final matchPosition = _matchPositions[_currentMatchIndex];
      final scrollRatio = matchPosition / totalChars;
      
      final maxScroll = _messageScrollController.position.maxScrollExtent;
      final targetScroll = (maxScroll * scrollRatio).clamp(0.0, maxScroll);
      
      // Centrar la coincidencia en la pantalla
      final viewportHeight = _messageScrollController.position.viewportDimension;
      final centerOffset = viewportHeight / 2;
      final centeredScroll = (targetScroll - centerOffset).clamp(0.0, maxScroll);
      
      _messageScrollController.animateTo(
        centeredScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadFontPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSizeMultiplier = prefs.getDouble('fontSizeMultiplier') ?? 1.0;
    });
  }

  Future<void> _saveFontPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSizeMultiplier', _fontSizeMultiplier);
  }

  void _increaseFontSize() {
    if (_fontSizeMultiplier < _maxMultiplier) {
      setState(() {
        _fontSizeMultiplier = (_fontSizeMultiplier + _step).clamp(_minMultiplier, _maxMultiplier);
      });
      _saveFontPreference();
    }
  }

  void _decreaseFontSize() {
    if (_fontSizeMultiplier > _minMultiplier) {
      setState(() {
        _fontSizeMultiplier = (_fontSizeMultiplier - _step).clamp(_minMultiplier, _maxMultiplier);
      });
      _saveFontPreference();
    }
  }

  void _resetFontSize() {
    setState(() {
      _fontSizeMultiplier = 1.0;
    });
    _saveFontPreference();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _dbHelper.getAllMessages();
      
      if (messages.isEmpty) {
        setState(() {
          _useDummyData = true;
          _messages = DummyData.getMessages();
          _messages.sort((a, b) => a.date.compareTo(b.date));
          _currentMessage = _messages.isNotEmpty ? _messages.first : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _useDummyData = false;
          _messages = messages;
          _currentMessage = messages.isNotEmpty ? messages.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _useDummyData = true;
        _messages = DummyData.getMessages();
        _messages.sort((a, b) => a.date.compareTo(b.date));
        _currentMessage = _messages.isNotEmpty ? _messages.first : null;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mensajes: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _onMessageSelected(Message message, {int? scrollToPosition, String? searchQuery}) {
    setState(() {
      _currentMessage = message;
      if (searchQuery != null) {
        _searchQuery = searchQuery;
        _searchController.text = searchQuery;
      } else {
        _searchQuery = '';
        _searchController.clear();
      }
      _currentMatchIndex = 0;
      _matchPositions.clear();
    });
    Navigator.of(context).pop();
    
    if (scrollToPosition != null) {
      // Navegar a una posición específica
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_messageScrollController.hasClients) {
          final totalChars = _currentMessage?.content.length ?? 1;
          final scrollRatio = scrollToPosition / totalChars;
          final maxScroll = _messageScrollController.position.maxScrollExtent;
          final targetScroll = (maxScroll * scrollRatio).clamp(0.0, maxScroll);
          
          // Centrar la coincidencia en la pantalla
          final viewportHeight = _messageScrollController.position.viewportDimension;
          final centerOffset = viewportHeight / 2;
          final centeredScroll = (targetScroll - centerOffset).clamp(0.0, maxScroll);
          
          _messageScrollController.animateTo(
            centeredScroll,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    } else {
      _scrollToTop();
    }
  }

  void _onSearchInCurrentMessage(String query) {
    setState(() {
      _searchQuery = query;
      _currentMatchIndex = 0;
    });
    
    // Scroll automático a la primera coincidencia si hay búsqueda
    if (query.isNotEmpty) {
      // Usar addPostFrameCallback para que el setState se complete primero
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMatch();
      });
    }
  }

  Future<void> _openImportScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImportScreen(),
      ),
    );

    if (result == true) {
      await _loadMessages();
    }
  }

  List<TextSpan> _highlightSearchText(String text) {
    if (_searchQuery.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final normalizedText = _normalize(text);
    final normalizedQuery = _normalize(_searchQuery);
    int start = 0;
    int matchIndex = 0;

    while (start < text.length) {
      final index = normalizedText.indexOf(normalizedQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Determinar si es la coincidencia actual
      final isCurrentMatch = matchIndex == _currentMatchIndex;
      
      spans.add(
        TextSpan(
          text: text.substring(index, index + normalizedQuery.length),
          style: TextStyle(
            backgroundColor: isCurrentMatch
                ? Colors.orange
                : Colors.yellow,
            color: Colors.black,
            fontWeight: isCurrentMatch ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );

      matchIndex++;
      start = index + normalizedQuery.length;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final currentFontSize = _baseFontSize * _fontSizeMultiplier;
    final matchCount = _currentMessage != null
        ? _countMatches(_currentMessage!.content, _searchQuery)
        : 0;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar en mensaje actual...',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón anterior
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                          tooltip: 'Anterior (Shift+Enter)',
                          onPressed: matchCount > 0 ? _navigateToPreviousMatch : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // Contador
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            matchCount > 0 ? '${_currentMatchIndex + 1}/$matchCount' : '0',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        // Botón siguiente
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                          tooltip: 'Siguiente (Enter)',
                          onPressed: matchCount > 0 ? _navigateToNextMatch : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // Botón limpiar
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchInCurrentMessage('');
                          },
                        ),
                      ],
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            onChanged: _onSearchInCurrentMessage,
            onSubmitted: (_) {
              if (matchCount > 0) {
                _navigateToNextMatch();
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Reducir tamaño (A-)',
            onPressed: _fontSizeMultiplier > _minMultiplier ? _decreaseFontSize : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Text(
                '${currentFontSize.round()}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Aumentar tamaño (A+)',
            onPressed: _fontSizeMultiplier < _maxMultiplier ? _increaseFontSize : null,
          ),
          if (_fontSizeMultiplier != 1.0)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Restablecer tamaño',
              onPressed: _resetFontSize,
            ),
          IconButton(
            icon: const Icon(Icons.menu_open),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      drawer: MessageListDrawer(
        messages: _messages,
        currentMessage: _currentMessage,
        onMessageSelected: (message) => _onMessageSelected(message),
        useDummyData: _useDummyData,
      ),
      endDrawer: GlobalSearchDrawer(
        messages: _messages,
        onMessageSelected: _onMessageSelected,
        useDummyData: _useDummyData,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _currentMessage == null
                      ? _buildEmptyState()
                      : _buildMessageViewer(currentFontSize),
                ),
                
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                
                Expanded(
                  flex: 1,
                  child: BibleViewer(fontSize: currentFontSize),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openImportScreen,
        icon: const Icon(Icons.upload_file),
        label: const Text('Importar PDFs'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 100,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay mensajes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _useDummyData
                ? 'Importa algunos PDFs para comenzar'
                : 'La base de datos está vacía',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _openImportScreen,
            icon: const Icon(Icons.upload_file),
            label: const Text('Importar PDFs'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageViewer(double fontSize) {
    return Column(
      children: [
        // Header sticky (no usa SliverAppBar)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título con badge inline
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentMessage!.title,
                      style: TextStyle(
                        fontSize: fontSize * 1.0, // Proporcional al zoom
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_useDummyData)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Prueba',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: fontSize * 0.5, // Proporcional
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Fecha
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: fontSize * 0.65, // Proporcional
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _formatMessageDate(_currentMessage!),
                    style: TextStyle(
                      fontSize: fontSize * 0.7, // Proporcional
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Header completo (multilínea)
              Text(
                _currentMessage!.header,
                style: TextStyle(
                  fontSize: fontSize * 0.7, // Proporcional
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        
        // Contenido con scroll
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                controller: _messageScrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 1.6,
                        ),
                        children: _highlightSearchText(_currentMessage!.content),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Formatea la fecha del mensaje usando dateDisplay si está disponible
  String _formatMessageDate(Message message) {
    if (message.dateDisplay != null) {
      // Es una fecha parcial, parsear y formatear el display
      final parts = message.dateDisplay!.split('-');
      final day = parts[0];
      final month = parts[1];
      final year = parts[2];
      
      const months = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      
      // Construir string basado en qué partes son 00
      if (day == '00' && month == '00') {
        return year; // Solo año
      } else if (day == '00') {
        final monthInt = int.parse(month);
        return '${months[monthInt - 1]} $year'; // Mes y año
      } else {
        final monthInt = int.parse(month);
        return '$day ${months[monthInt - 1]} $year'; // Fecha completa (no debería llegar aquí)
      }
    }
    
    // Fecha completa, usar formato normal
    return _formatDate(message.date);
  }
}
