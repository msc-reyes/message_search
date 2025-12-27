import 'dart:io';
import '../models/message.dart';

class PdfExtractionResult {
  final String preacher;
  final String location;
  final String content;

  PdfExtractionResult({
    required this.preacher,
    required this.location,
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
  /// Extrae preacher, location y content del contenido del PDF
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
      preacher: extractionResult.preacher,
      location: extractionResult.location,
      content: extractionResult.content,
      pdfPath: pdfPath,
    );
  }

  /// Extrae el texto completo del PDF usando pdftotext
  /// 
  /// Retorna un PdfExtractionResult con:
  /// - preacher: Línea 2 completa (ej: "Predicado por el Hno. Bernabé G. García")
  /// - location: Línea 4 completa (ej: "En Phoenix, Arizona U.S.A")
  /// - content: Todo el texto desde la línea 5 en adelante
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
      );

      if (result.exitCode != 0) {
        throw Exception('Error al extraer texto del PDF: ${result.stderr}');
      }

      final fullText = result.stdout as String;
      
      // Separar por líneas
      final lines = fullText.split('\n');
      
      // Validar que hay suficientes líneas
      if (lines.length < 5) {
        throw Exception(
          'El PDF no tiene el formato esperado. '
          'Se esperan al menos 5 líneas (título, predicador, fecha, lugar, contenido)'
        );
      }

      // Extraer datos según el formato:
      // Línea 1: Título (se ignora, viene del nombre del archivo)
      // Línea 2: Predicador (ej: "Predicado por el Hno. Bernabé G. García")
      // Línea 3: Fecha (se ignora, viene del nombre del archivo)
      // Línea 4: Lugar (ej: "En Phoenix, Arizona U.S.A")
      // Línea 5+: Contenido del mensaje
      
      final preacher = lines[1].trim();
      final location = lines[3].trim();
      final contentLines = lines.sublist(4); // Desde línea 5 en adelante
      final content = contentLines.join('\n').trim();

      // Validaciones básicas
      if (preacher.isEmpty) {
        throw Exception('No se pudo extraer el predicador (línea 2 vacía)');
      }
      
      if (location.isEmpty) {
        throw Exception('No se pudo extraer la ubicación (línea 4 vacía)');
      }
      
      if (content.isEmpty) {
        throw Exception('No se pudo extraer el contenido del mensaje');
      }

      return PdfExtractionResult(
        preacher: preacher,
        location: location,
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
