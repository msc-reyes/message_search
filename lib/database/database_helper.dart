import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('messages.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Inicializar FFI para desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla principal de mensajes
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        date_display TEXT,
        header TEXT NOT NULL,
        pdf_path TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla FTS5 para búsqueda full-text con normalización
    await db.execute('''
      CREATE VIRTUAL TABLE messages_fts USING fts5(
        title,
        content,
        content=messages,
        content_rowid=id,
        tokenize='unicode61 remove_diacritics 2'
      )
    ''');

    // Triggers para mantener FTS5 sincronizado
    await db.execute('''
      CREATE TRIGGER messages_ai AFTER INSERT ON messages BEGIN
        INSERT INTO messages_fts(rowid, title, content)
        VALUES (new.id, new.title, new.content);
      END
    ''');

    await db.execute('''
      CREATE TRIGGER messages_ad AFTER DELETE ON messages BEGIN
        DELETE FROM messages_fts WHERE rowid = old.id;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER messages_au AFTER UPDATE ON messages BEGIN
        UPDATE messages_fts 
        SET title = new.title, content = new.content
        WHERE rowid = new.id;
      END
    ''');
  }

  Future<String> getDatabasesPath() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final directory = await getApplicationDocumentsDirectory();
      final dbDir = Directory(join(directory.path, 'MessageSearchDB'));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      return dbDir.path;
    }
    return await getDatabasesPath();
  }

  // Crear mensaje
  Future<Message> createMessage(Message message) async {
    final db = await database;
    final id = await db.insert('messages', message.toMap());
    return message.copyWith(id: id);
  }

  // Obtener todos los mensajes
  Future<List<Message>> getAllMessages() async {
    final db = await database;
    final result = await db.query(
      'messages',
      orderBy: 'date ASC',
    );
    return result.map((json) => Message.fromMap(json)).toList();
  }

  // Obtener mensaje por ID
  Future<Message?> getMessageById(int id) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Message.fromMap(maps.first);
    }
    return null;
  }

  // Búsqueda por título
  Future<List<Message>> searchByTitle(String query) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date ASC',
    );
    return result.map((json) => Message.fromMap(json)).toList();
  }

  // Búsqueda por fecha
  Future<List<Message>> searchByDate(String query) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: 'date LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date ASC',
    );
    return result.map((json) => Message.fromMap(json)).toList();
  }

  // Búsqueda full-text (global) usando FTS5
  Future<List<MessageSearchResult>> searchFullText(String query) async {
    final db = await database;
    
    // Escapar caracteres especiales de FTS5
    final escapedQuery = query.replaceAll('"', '""');
    
    // Buscar frases exactas si contiene espacios
    final ftsQuery = query.contains(' ') ? '"$escapedQuery"' : escapedQuery;

    final result = await db.rawQuery('''
      SELECT 
        m.*,
        snippet(messages_fts, 1, '<mark>', '</mark>', '...', 30) as snippet,
        (
          SELECT COUNT(*)
          FROM messages_fts
          WHERE messages_fts MATCH ?
          AND rowid = m.id
        ) as match_count
      FROM messages m
      INNER JOIN messages_fts ON messages_fts.rowid = m.id
      WHERE messages_fts MATCH ?
      ORDER BY match_count DESC, m.date DESC
    ''', [ftsQuery, ftsQuery]);

    return result.map((json) {
      final message = Message.fromMap(json);
      final snippet = json['snippet'] as String? ?? '';
      final matchCount = json['match_count'] as int? ?? 0;
      
      return MessageSearchResult(
        message: message,
        snippet: snippet.replaceAll('<mark>', '').replaceAll('</mark>', ''),
        matchCount: matchCount,
      );
    }).toList();
  }

  // Actualizar mensaje
  Future<int> updateMessage(Message message) async {
    final db = await database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  // Eliminar mensaje
  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Contar total de mensajes
  Future<int> getMessagesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM messages');
    // Corregido: usar result.first en lugar de Sqflite.firstIntValue
    return result.isNotEmpty ? (result.first['count'] as int? ?? 0) : 0;
  }

  // Verificar si existe un PDF
  Future<bool> pdfExists(String pdfPath) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: 'pdf_path = ?',
      whereArgs: [pdfPath],
    );
    return result.isNotEmpty;
  }

  // Cerrar base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Limpiar base de datos (para testing)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'messages.db');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    _database = null;
  }
}

// Clase para resultados de búsqueda
class MessageSearchResult {
  final Message message;
  final String snippet;
  final int matchCount;

  MessageSearchResult({
    required this.message,
    required this.snippet,
    required this.matchCount,
  });
}
