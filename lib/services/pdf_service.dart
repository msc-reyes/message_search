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
    return 'El Amor de Dios-15-08-2010.pdf';
  }

  /// Extrae título y fecha del nombre del archivo
  /// Retorna un Map con 'title' (String) y 'date' (DateTime)
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
    final day = int.parse(match.group(2)!);
    final month = int.parse(match.group(3)!);
    final year = int.parse(match.group(4)!);

    // Validar fecha
    try {
      final date = DateTime(year, month, day);
      return {
        'title': title,
        'date': date,
      };
    } catch (e) {
      throw Exception('Fecha inválida en nombre de archivo: $fileName');
    }
  }

  /// Crea un Message completo desde un archivo PDF
  /// Extrae título y fecha del nombre del archivo
  /// Extrae header y content del contenido del PDF
  Future<Message> createMessageFromPDF(String pdfPath) async {
    // Obtener nombre del archivo
    final fileName = pdfPath.split(Platform.pathSeparator).last;
    
    // Extraer título y fecha del nombre
    final fileNameData = parseFileName(fileName);
    final title = fileNameData['title'] as String;
    final date = fileNameData['date'] as DateTime;

    // Extraer contenido del PDF
    final extractionResult = await extractTextFromPdf(pdfPath);

    // Crear y retornar mensaje
    return Message(
      title: title,
      date: date,
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
