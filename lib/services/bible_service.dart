import 'dart:convert';
import 'package:flutter/services.dart';

class BibleVerse {
  final String bookName;
  final int book;
  final int chapter;
  final int verse;
  final String text;

  BibleVerse({
    required this.bookName,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      bookName: json['book_name'] as String,
      book: json['book'] as int,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      text: json['text'] as String,
    );
  }
}

class BibleData {
  final Map<String, dynamic> metadata;
  final List<BibleVerse> verses;

  BibleData({
    required this.metadata,
    required this.verses,
  });
}

class BibleService {
  static final BibleService instance = BibleService._();
  BibleService._();

  final Map<String, BibleData> _loadedBibles = {};
  
  final Map<String, String> availableVersions = {
    'RV 1909': 'assets/bibles/rv_1909.json',
    'RV 1909 Strong': 'assets/bibles/rv_1909_strongs.json',
    'KJV': 'assets/bibles/kjv.json',
  };

  Future<BibleData> loadBible(String versionKey) async {
    if (_loadedBibles.containsKey(versionKey)) {
      return _loadedBibles[versionKey]!;
    }

    final path = availableVersions[versionKey];
    if (path == null) {
      throw Exception('Versión no encontrada: $versionKey');
    }

    final jsonString = await rootBundle.loadString(path);
    final jsonData = json.decode(jsonString);

    final metadata = jsonData['metadata'] as Map<String, dynamic>;
    final versesJson = jsonData['verses'] as List;
    final verses = versesJson.map((v) => BibleVerse.fromJson(v)).toList();

    final bibleData = BibleData(metadata: metadata, verses: verses);
    _loadedBibles[versionKey] = bibleData;

    return bibleData;
  }

  List<String> getBooks(BibleData bible) {
    final books = <String>[];
    String? lastBook;
    
    for (final verse in bible.verses) {
      if (verse.bookName != lastBook) {
        books.add(verse.bookName);
        lastBook = verse.bookName;
      }
    }
    
    return books;
  }

  int getChapterCount(BibleData bible, String bookName) {
    int maxChapter = 0;
    
    for (final verse in bible.verses) {
      if (verse.bookName == bookName && verse.chapter > maxChapter) {
        maxChapter = verse.chapter;
      }
    }
    
    return maxChapter;
  }

  List<BibleVerse> getChapter(BibleData bible, String bookName, int chapter) {
    return bible.verses
        .where((v) => v.bookName == bookName && v.chapter == chapter)
        .toList();
  }

  Future<void> preloadAllVersions() async {
    for (final version in availableVersions.keys) {
      await loadBible(version);
    }
  }
}
