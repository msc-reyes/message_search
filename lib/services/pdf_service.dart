import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/message.dart';

class PDFService {
  // Extraer texto de un archivo PDF
  Future<String> extractTextFromPDF(String pdfPath) async {
    try {
      final File file = File(pdfPath);
      
      if (!await file.exists()) {
        throw Exception('El archivo PDF no existe: $pdfPath');
      }

      String extractedText = '';
      
      // Intentar primero con pdftotext (más preciso)
      try {
        extractedText = await _extractWithPdfToText(pdfPath);
        print('✅ Texto extraído con pdftotext');
      } catch (e) {
        // Si falla, usar Syncfusion como fallback
        print('⚠️ pdftotext no disponible, usando Syncfusion');
        extractedText = await _extractWithSyncfusion(file);
      }
      
      // Limpiar texto (solo limpieza básica)
      extractedText = _cleanText(extractedText);
      
      return extractedText;
    } catch (e) {
      throw Exception('Error al extraer texto del PDF: $e');
    }
  }

  // Extraer con pdftotext (Poppler) - MÁS PRECISO
  Future<String> _extractWithPdfToText(String pdfPath) async {
    // Ejecutar pdftotext
    final result = await Process.run(
      'pdftotext',
      ['-layout', pdfPath, '-'],
    );
    
    if (result.exitCode != 0) {
      throw Exception('pdftotext falló: ${result.stderr}');
    }
    
    return result.stdout.toString();
  }

  // Extraer con Syncfusion - FALLBACK
  Future<String> _extractWithSyncfusion(File file) async {
    final PdfDocument document = PdfDocument(inputBytes: await file.readAsBytes());
    String extractedText = PdfTextExtractor(document).extractText();
    document.dispose();
    return extractedText;
  }

  // Limpiar texto - SOLO LIMPIEZA BÁSICA
  String _cleanText(String text) {
    // 1. Remover espacios múltiples (pero preservar saltos de línea)
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    
    // 2. Convertir múltiples saltos de línea en máximo doble salto
    text = text.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');
    
    // 3. Limpiar espacios al inicio y final de cada línea
    final lines = text.split('\n');
    text = lines.map((line) => line.trim()).join('\n');
    
    // 4. Trim general
    text = text.trim();
    
    return text;
  }

  // Extraer título y fecha del nombre del archivo
  // Formato esperado: "Título del mensaje-DD-MM-AAAA.pdf"
  Map<String, dynamic> parseFileName(String fileName) {
    try {
      // Remover la extensión .pdf
      String nameWithoutExt = fileName.replaceAll('.pdf', '').replaceAll('.PDF', '');
      
      // Buscar el patrón de fecha al final: DD-MM-AAAA
      final RegExp datePattern = RegExp(r'-(\d{2})-(\d{2})-(\d{4})$');
      final match = datePattern.firstMatch(nameWithoutExt);
      
      if (match == null) {
        throw Exception('Formato de nombre de archivo inválido. Esperado: "Título-DD-MM-AAAA.pdf"');
      }
      
      // Extraer día, mes, año
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      
      // Validar fecha
      if (month < 1 || month > 12) {
        throw Exception('Mes inválido: $month');
      }
      if (day < 1 || day > 31) {
        throw Exception('Día inválido: $day');
      }
      
      final date = DateTime(year, month, day);
      
      // Extraer título (todo antes del patrón de fecha)
      final title = nameWithoutExt.substring(0, match.start);
      
      // Limpiar título (remover guiones extras y espacios)
      final cleanTitle = title.trim().replaceAll('_', ' ');
      
      if (cleanTitle.isEmpty) {
        throw Exception('El título no puede estar vacío');
      }
      
      return {
        'title': cleanTitle,
        'date': date,
      };
    } catch (e) {
      throw Exception('Error al parsear nombre de archivo "$fileName": $e');
    }
  }

  // Crear un Message desde un archivo PDF
  Future<Message> createMessageFromPDF(String pdfPath) async {
    try {
      // Obtener nombre del archivo
      final fileName = pdfPath.split(Platform.pathSeparator).last;
      
      // Parsear título y fecha del nombre
      final parsed = parseFileName(fileName);
      final title = parsed['title'] as String;
      final date = parsed['date'] as DateTime;
      
      // Extraer contenido del PDF
      final content = await extractTextFromPDF(pdfPath);
      
      if (content.isEmpty) {
        throw Exception('El PDF no contiene texto extraíble');
      }
      
      // Crear mensaje
      return Message(
        title: title,
        date: date,
        content: content,
        pdfPath: pdfPath,
      );
    } catch (e) {
      throw Exception('Error al crear mensaje desde PDF "$pdfPath": $e');
    }
  }

  // Procesar múltiples PDFs
  Future<List<Message>> createMessagesFromPDFs(List<String> pdfPaths, {
    Function(int current, int total)? onProgress,
  }) async {
    final messages = <Message>[];
    
    for (int i = 0; i < pdfPaths.length; i++) {
      try {
        final message = await createMessageFromPDF(pdfPaths[i]);
        messages.add(message);
        
        // Callback de progreso
        if (onProgress != null) {
          onProgress(i + 1, pdfPaths.length);
        }
      } catch (e) {
        // Log error pero continúa con los demás archivos
        print('Error procesando ${pdfPaths[i]}: $e');
      }
    }
    
    return messages;
  }

  // Validar formato de nombre de archivo
  bool isValidFileName(String fileName) {
    try {
      parseFileName(fileName);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtener ejemplo de formato válido
  String getFileNameExample() {
    return 'El amor de Dios-15-03-2010.pdf';
  }
}
