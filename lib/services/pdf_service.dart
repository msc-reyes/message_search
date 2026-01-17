import 'dart:io';
import 'dart:convert';
import '../models/message.dart';

class PdfExtractionResult {
  final String header;
  final String content;

  PdfExtractionResult({
    required this.header,
    required this.content,
  });
}

class PdfService {
  /// Formato esperado del nombre de archivo: Título-DD-MM-AAAA.pdf
  /// Ejemplo: "El Amor de Dios-15-08-2010.pdf"
  static final RegExp _fileNamePattern = RegExp(
    r'^(.+)-(\d{2})-(\d{2})-(\d{4})\.pdf$',
    caseSensitive: false,
  );

  /// Valida si el nombre del archivo tiene el formato correcto
  bool isValidFileName(String fileName) {
    return _fileNamePattern.hasMatch(fileName);
  }

  /// Retorna un ejemplo del formato de nombre esperado
  String getFileNameExample() {
    return 'El Amor de Dios-15-08-2010.pdf (o -00-08-2010.pdf si no hay día, o -00-00-2010.pdf si solo hay año)';
  }

  /// Extrae título y fecha del nombre del archivo
  /// Retorna un Map con:
  /// - 'title' (String): Título del mensaje
  /// - 'date' (DateTime): Fecha para ordenar (con día/mes = 1 si falta)
  /// - 'dateDisplay' (String?): Fecha original si es parcial, null si es completa
  /// 
  /// Soporta formatos:
  /// - Completo: Título-15-08-2010.pdf → date: 15-08-2010, dateDisplay: null
  /// - Sin día: Título-00-08-2010.pdf → date: 01-08-2010, dateDisplay: "00-08-2010"
  /// - Solo año: Título-00-00-2010.pdf → date: 01-01-2010, dateDisplay: "00-00-2010"
  /// 
  /// Lanza excepción si el formato es inválido
  Map<String, dynamic> parseFileName(String fileName) {
    final match = _fileNamePattern.firstMatch(fileName);
    
    if (match == null) {
      throw Exception(
        'Formato de nombre inválido: $fileName\n'
        'Formato esperado: ${getFileNameExample()}'
      );
    }

    final title = match.group(1)!.trim();
    final dayStr = match.group(2)!;
    final monthStr = match.group(3)!;
    final yearStr = match.group(4)!;
    
    final day = int.parse(dayStr);
    final month = int.parse(monthStr);
    final year = int.parse(yearStr);

    // Detectar si es fecha parcial
    final isPartialDate = day == 0 || month == 0;
    
    // Crear fecha para BD (con relleno si es necesario)
    final dateForDb = DateTime(
      year,
      month == 0 ? 1 : month,  // Si mes es 0, usar 1
      day == 0 ? 1 : day,      // Si día es 0, usar 1
    );
    
    // Crear dateDisplay solo si es fecha parcial
    final String? dateDisplay = isPartialDate 
        ? '$dayStr-$monthStr-$yearStr' 
        : null;

    return {
      'title': title,
      'date': dateForDb,
      'dateDisplay': dateDisplay,
    };
  }

  /// Crea un Message completo desde un archivo PDF
  /// Extrae título, fecha y dateDisplay del nombre del archivo
  /// Extrae header y content del contenido del PDF
  Future<Message> createMessageFromPDF(String pdfPath) async {
    // Obtener nombre del archivo
    final fileName = pdfPath.split(Platform.pathSeparator).last;
    
    // Extraer título, fecha y dateDisplay del nombre
    final fileNameData = parseFileName(fileName);
    final title = fileNameData['title'] as String;
    final date = fileNameData['date'] as DateTime;
    final dateDisplay = fileNameData['dateDisplay'] as String?;

    // Extraer contenido del PDF
    final extractionResult = await extractTextFromPdf(pdfPath);

    // Crear y retornar mensaje
    return Message(
      title: title,
      date: date,
      dateDisplay: dateDisplay,
      header: extractionResult.header,
      content: extractionResult.content,
      pdfPath: pdfPath,
    );
  }

  /// Extrae el texto completo del PDF usando pdftotext
  /// 
  /// Retorna un PdfExtractionResult con:
  /// - header: Todo el texto entre los asteriscos * ... *
  /// - content: Todo el texto después del segundo asterisco
  Future<PdfExtractionResult> extractTextFromPdf(String pdfPath) async {
    try {
      // Ejecutar pdftotext para extraer el texto
      final result = await Process.run(
        'pdftotext',
        [
          '-layout',  // Mantener el layout original
          '-nopgbrk', // Sin saltos de página
          pdfPath,
          '-',        // Salida a stdout
        ],
        stdoutEncoding: utf8, // Solución para acentos en Windows
      );

      if (result.exitCode != 0) {
        throw Exception('Error al extraer texto del PDF: ${result.stderr}');
      }

      final fullText = result.stdout as String;
      
      // Buscar el primer asterisco
      final firstAsteriskIndex = fullText.indexOf('*');
      if (firstAsteriskIndex == -1) {
        throw Exception(
          'No se encontró el delimitador de inicio del header (*). '
          'Verifica que el PDF tenga el formato correcto con el header entre asteriscos.'
        );
      }

      // Buscar el segundo asterisco (después del primero)
      final secondAsteriskIndex = fullText.indexOf('*', firstAsteriskIndex + 1);
      if (secondAsteriskIndex == -1) {
        throw Exception(
          'No se encontró el delimitador de fin del header (*). '
          'Verifica que el PDF tenga el formato correcto con el header entre asteriscos.'
        );
      }

      // Extraer header (sin los asteriscos)
      final headerRaw = fullText.substring(
        firstAsteriskIndex + 1,
        secondAsteriskIndex,
      ).trim();
      
      // Limpiar espacios de cada línea del header (para textos centrados o con indentación)
      final headerLines = headerRaw.split('\n');
      final cleanedHeaderLines = headerLines.map((line) => line.trim()).toList();
      final header = cleanedHeaderLines.join('\n');

      // Extraer contenido (después del segundo asterisco)
      final content = fullText.substring(secondAsteriskIndex + 1).trim();

      // Validaciones básicas
      if (header.isEmpty) {
        throw Exception('El header está vacío (texto entre asteriscos)');
      }
      
      if (content.isEmpty) {
        throw Exception('No se pudo extraer el contenido del mensaje');
      }

      return PdfExtractionResult(
        header: header,
        content: content,
      );
      
    } catch (e) {
      throw Exception('Error al procesar PDF: $e');
    }
  }

  /// Verifica si pdftotext está instalado en el sistema
  Future<bool> isPdftotextAvailable() async {
    try {
      final result = await Process.run('which', ['pdftotext']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la versión de pdftotext instalada
  Future<String?> getPdftotextVersion() async {
    try {
      final result = await Process.run('pdftotext', ['-v']);
      return result.stderr.toString().split('\n').first;
    } catch (e) {
      return null;
    }
  }
}
