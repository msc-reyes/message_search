import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/pdf_service.dart';
import '../database/database_helper.dart';
import '../models/message.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final PdfService _pdfService = PdfService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  bool _isImporting = false;
  double _progress = 0.0;
  int _totalFiles = 0;
  int _processedFiles = 0;
  int _successCount = 0;
  int _errorCount = 0;
  List<String> _errors = [];
  List<String> _selectedFiles = [];

  Future<void> _selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths.where((path) => path != null).cast<String>().toList();
          _errors.clear();
          _successCount = 0;
          _errorCount = 0;
        });

        // Validar nombres de archivos
        _validateFileNames();
      }
    } catch (e) {
      _showError('Error al seleccionar archivos: $e');
    }
  }

  void _validateFileNames() {
    final invalidFiles = <String>[];
    
    for (final filePath in _selectedFiles) {
      final fileName = filePath.split(Platform.pathSeparator).last;
      if (!_pdfService.isValidFileName(fileName)) {
        invalidFiles.add(fileName);
      }
    }

    if (invalidFiles.isNotEmpty) {
      setState(() {
        _errors.add('Archivos con formato inválido:');
        _errors.addAll(invalidFiles.map((f) => '  • $f'));
        _errors.add('');
        _errors.add('Formato esperado: ${_pdfService.getFileNameExample()}');
      });
    }
  }

  Future<void> _importFiles() async {
    if (_selectedFiles.isEmpty) {
      _showError('No hay archivos seleccionados');
      return;
    }

    setState(() {
      _isImporting = true;
      _progress = 0.0;
      _totalFiles = _selectedFiles.length;
      _processedFiles = 0;
      _successCount = 0;
      _errorCount = 0;
      _errors.clear();
    });

    try {
      for (int i = 0; i < _selectedFiles.length; i++) {
        final filePath = _selectedFiles[i];
        final fileName = filePath.split(Platform.pathSeparator).last;

        try {
          // Verificar si ya existe
          if (await _dbHelper.pdfExists(filePath)) {
            setState(() {
              _errors.add('Omitido (ya existe): $fileName');
              _errorCount++;
            });
            continue;
          }

          // Crear mensaje desde PDF
          final message = await _pdfService.createMessageFromPDF(filePath);
          
          // Guardar en base de datos
          await _dbHelper.createMessage(message);
          
          setState(() {
            _successCount++;
          });
        } catch (e) {
          setState(() {
            _errors.add('Error en $fileName: $e');
            _errorCount++;
          });
        } finally {
          setState(() {
            _processedFiles++;
            _progress = _processedFiles / _totalFiles;
          });
        }
      }

      // Mostrar resumen
      _showSuccess();
    } catch (e) {
      _showError('Error durante la importación: $e');
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importación Completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total de archivos: $_totalFiles'),
            Text('Importados exitosamente: $_successCount',
                style: const TextStyle(color: Colors.green)),
            if (_errorCount > 0)
              Text('Errores: $_errorCount',
                  style: const TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_successCount > 0) {
                Navigator.of(context).pop(true); // Volver y recargar
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedFiles.clear();
      _errors.clear();
      _successCount = 0;
      _errorCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Mensajes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instrucciones
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Formato de Nombres de Archivo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los archivos PDF deben tener el formato:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _pdfService.getFileNameExample(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Donde: Título-DD-MM-AAAA.pdf',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _selectFiles,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Seleccionar PDFs'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedFiles.isEmpty || _isImporting
                        ? null
                        : _importFiles,
                    icon: const Icon(Icons.upload),
                    label: const Text('Importar'),
                  ),
                ),
              ],
            ),
            
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _isImporting ? null : _clearSelection,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar Selección'),
              ),
            ],

            const SizedBox(height: 24),

            // Progreso
            if (_isImporting) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(
                'Procesando: $_processedFiles / $_totalFiles',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Lista de archivos seleccionados y errores
            Expanded(
              child: Card(
                child: _selectedFiles.isEmpty && _errors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay archivos seleccionados',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (_selectedFiles.isNotEmpty) ...[
                            Text(
                              'Archivos Seleccionados (${_selectedFiles.length}):',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ..._selectedFiles.map((file) {
                              final fileName = file.split(Platform.pathSeparator).last;
                              final isValid = _pdfService.isValidFileName(fileName);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      isValid ? Icons.check_circle : Icons.error,
                                      size: 16,
                                      color: isValid ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        fileName,
                                        style: TextStyle(
                                          color: isValid
                                              ? null
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                          
                          if (_errors.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Mensajes:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ..._errors.map((error) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    error,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                                )),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
