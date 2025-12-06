import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bible_service.dart';

class BibleViewer extends StatefulWidget {
  final double fontSize;

  const BibleViewer({super.key, required this.fontSize});

  @override
  State<BibleViewer> createState() => _BibleViewerState();
}

class _BibleViewerState extends State<BibleViewer> {
  final BibleService _bibleService = BibleService.instance;
  final ScrollController _scrollController = ScrollController();
  
  String _selectedVersion = 'RV 1909';
  String? _selectedBook;
  int _selectedChapter = 1;
  
  BibleData? _currentBible;
  List<String> _books = [];
  List<BibleVerse> _currentChapterVerses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _selectedVersion = prefs.getString('bibleVersion') ?? 'RV 1909';
      _selectedBook = prefs.getString('bibleBook');
      _selectedChapter = prefs.getInt('bibleChapter') ?? 1;
    });
    
    await _loadBible();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bibleVersion', _selectedVersion);
    if (_selectedBook != null) {
      await prefs.setString('bibleBook', _selectedBook!);
    }
    await prefs.setInt('bibleChapter', _selectedChapter);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _loadBible() async {
    setState(() => _isLoading = true);

    try {
      final bible = await _bibleService.loadBible(_selectedVersion);
      final books = _bibleService.getBooks(bible);
      
      setState(() {
        _currentBible = bible;
        _books = books;
        
        if (_selectedBook == null || !books.contains(_selectedBook)) {
          _selectedBook = books.first;
          _selectedChapter = 1;
        }
        
        _loadChapter();
        _isLoading = false;
      });
      
      _scrollToTop();
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la Biblia: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadChapter() {
    if (_currentBible == null || _selectedBook == null) return;
    
    final verses = _bibleService.getChapter(
      _currentBible!,
      _selectedBook!,
      _selectedChapter,
    );
    
    setState(() {
      _currentChapterVerses = verses;
    });
    
    _scrollToTop();
  }

  void _onVersionChanged(String? version) {
    if (version == null) return;
    
    setState(() {
      _selectedVersion = version;
    });
    
    _loadBible();
    _savePreferences();
  }

  void _onBookChanged(String? book) {
    if (book == null || _currentBible == null) return;
    
    setState(() {
      _selectedBook = book;
      _selectedChapter = 1;
    });
    
    _loadChapter();
    _savePreferences();
  }

  void _onChapterChanged(int? chapter) {
    if (chapter == null) return;
    
    setState(() {
      _selectedChapter = chapter;
    });
    
    _loadChapter();
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedVersion,
                      decoration: const InputDecoration(
                        labelText: 'Versión',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _bibleService.availableVersions.keys.map((version) {
                        return DropdownMenuItem(
                          value: version,
                          child: Text(version),
                        );
                      }).toList(),
                      onChanged: _isLoading ? null : _onVersionChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedBook,
                      decoration: const InputDecoration(
                        labelText: 'Libro',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _books.map((book) {
                        return DropdownMenuItem(
                          value: book,
                          child: Text(book),
                        );
                      }).toList(),
                      onChanged: _isLoading ? null : _onBookChanged,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<int>(
                      value: _selectedChapter,
                      decoration: const InputDecoration(
                        labelText: 'Cap.',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _currentBible != null && _selectedBook != null
                          ? List.generate(
                              _bibleService.getChapterCount(_currentBible!, _selectedBook!),
                              (index) => index + 1,
                            ).map((chapter) {
                              return DropdownMenuItem(
                                value: chapter,
                                child: Text('$chapter'),
                              );
                            }).toList()
                          : [],
                      onChanged: _isLoading ? null : _onChapterChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentChapterVerses.isEmpty
                  ? const Center(child: Text('No hay versículos disponibles'))
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(24),
                          itemCount: _currentChapterVerses.length,
                          itemBuilder: (context, index) {
                            final verse = _currentChapterVerses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: widget.fontSize,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    height: 1.6,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${verse.verse} ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: widget.fontSize * 0.9,
                                      ),
                                    ),
                                    TextSpan(text: verse.text),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
