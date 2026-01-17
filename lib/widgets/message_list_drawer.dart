import 'package:flutter/material.dart';
import '../models/message.dart';
import '../database/database_helper.dart';

class MessageListDrawer extends StatefulWidget {
  final List<Message> messages;
  final Message? currentMessage;
  final Function(Message) onMessageSelected;
  final bool useDummyData;

  const MessageListDrawer({
    super.key,
    required this.messages,
    required this.currentMessage,
    required this.onMessageSelected,
    required this.useDummyData,
  });

  @override
  State<MessageListDrawer> createState() => _MessageListDrawerState();
}

class _MessageListDrawerState extends State<MessageListDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  String _searchQuery = '';
  String _searchType = 'title'; // 'title' o 'date'
  List<Message> _filteredMessages = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredMessages = widget.messages;
  }

  @override
  void didUpdateWidget(MessageListDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _filterMessages(_searchQuery);
    }
  }

  Future<void> _filterMessages(String query) async {
    setState(() {
      _searchQuery = query.toLowerCase();
      _isSearching = true;
    });

    try {
      if (_searchQuery.isEmpty) {
        setState(() {
          _filteredMessages = widget.messages;
          _isSearching = false;
        });
        return;
      }

      if (widget.useDummyData) {
        // Búsqueda en memoria para datos dummy
        setState(() {
          _filteredMessages = widget.messages.where((message) {
            if (_searchType == 'title') {
              return message.title.toLowerCase().contains(_searchQuery);
            } else {
              return _formatMessageDate(message).toLowerCase().contains(_searchQuery);
            }
          }).toList();
          _isSearching = false;
        });
      } else {
        // Búsqueda en base de datos
        List<Message> results;
        if (_searchType == 'title') {
          results = await _dbHelper.searchByTitle(_searchQuery);
        } else {
          results = await _dbHelper.searchByDate(_searchQuery);
        }

        setState(() {
          _filteredMessages = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _filteredMessages = [];
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

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
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
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      
      // Construir string basado en qué partes son 00
      if (day == '00' && month == '00') {
        return year; // Solo año
      } else if (day == '00') {
        final monthInt = int.parse(month);
        return '${months[monthInt - 1]} $year'; // Mes y año
      } else {
        final monthInt = int.parse(month);
        return '$day ${months[monthInt - 1]} $year'; // Fecha completa
      }
    }
    
    // Fecha completa, usar formato normal
    return _formatDate(message.date);
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
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lista de Mensajes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.messages.length} mensajes disponibles',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                  ),
                  if (widget.useDummyData) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Datos de prueba',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterMessages('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _filterMessages,
                ),
                const SizedBox(height: 12),

                // Radio buttons para tipo de búsqueda
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Título'),
                        value: 'title',
                        groupValue: _searchType,
                        onChanged: (value) {
                          setState(() {
                            _searchType = value!;
                            _filterMessages(_searchQuery);
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Fecha'),
                        value: 'date',
                        groupValue: _searchType,
                        onChanged: (value) {
                          setState(() {
                            _searchType = value!;
                            _filterMessages(_searchQuery);
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),

          // Lista de mensajes
          Expanded(
            child: _filteredMessages.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron mensajes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = _filteredMessages[index];
                      final isSelected = widget.currentMessage?.id == message.id;

                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.3)
                              : null,
                          border: Border(
                            left: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 4,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            message.title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(_formatMessageDate(message)),
                          onTap: () => widget.onMessageSelected(message),
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
