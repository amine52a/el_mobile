import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/course_provider.dart';
import '../../data/models/resource.dart';

/// Screen for viewing PDF resources (F2.2.2)
class PdfViewerScreen extends StatefulWidget {
  final Resource resource;
  final int courseId;
  final String userId;

  const PdfViewerScreen({
    super.key,
    required this.resource,
    required this.courseId,
    required this.userId,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  DateTime? _startTime;
  bool _isLoading = true;
  String? _errorMessage;
  String? _localFilePath; // Path to locally saved PDF
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _checkUrl();
  }

  void _checkUrl() async {
    if (widget.resource.url == null || widget.resource.url!.isEmpty) {
      setState(() {
        _errorMessage = 'URL du PDF non disponible';
        _isLoading = false;
      });
    } else if (widget.resource.url!.startsWith('local://')) {
      // Handle local file path
      final localPath = widget.resource.url!.replaceFirst('local://', '');
      final file = File(localPath);
      
      if (await file.exists()) {
        setState(() {
          _localFilePath = localPath;
          _isDownloaded = true;
          _isLoading = false;
        });
        print('📁 Fichier local trouvé: $localPath');
      } else {
        setState(() {
          _errorMessage = 'Fichier local introuvable';
          _isLoading = false;
        });
      }
    } else {
      // Check if PDF is already downloaded locally
      await _checkLocalFile();
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check if PDF is already saved locally
  Future<void> _checkLocalFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = _getFileNameFromUrl(widget.resource.url!);
      final file = File('${dir.path}/pdfs/$fileName');
      
      if (await file.exists()) {
        setState(() {
          _localFilePath = file.path;
          _isDownloaded = true;
        });
        print('📁 PDF déjà téléchargé: ${file.path}');
      }
    } catch (e) {
      print('❌ Erreur vérification fichier local: $e');
    }
  }

  /// Extract filename from URL
  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    String name = uri.pathSegments.last;
    if (!name.endsWith('.pdf')) {
      name = '${widget.resource.id}.pdf';
    }
    return name;
  }

  /// Download PDF to local storage
  Future<void> _downloadToLocal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = widget.resource.url!;
      print('⬇️ Téléchargement depuis: $url');
      
      // Download file
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Get app directory
        final dir = await getApplicationDocumentsDirectory();
        final pdfDir = Directory('${dir.path}/pdfs');
        
        // Create directory if it doesn't exist
        if (!await pdfDir.exists()) {
          await pdfDir.create(recursive: true);
        }
        
        // Save file
        final fileName = _getFileNameFromUrl(url);
        final file = File('${pdfDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        setState(() {
          _localFilePath = file.path;
          _isDownloaded = true;
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ PDF téléchargé ! Disponible hors ligne'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        print('✅ PDF sauvegardé: ${file.path}');
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur de téléchargement: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('❌ Erreur téléchargement: $e');
    }
  }

  /// Delete local PDF file
  Future<void> _deleteLocalFile() async {
    try {
      if (_localFilePath != null) {
        final file = File(_localFilePath!);
        if (await file.exists()) {
          await file.delete();
          setState(() {
            _localFilePath = null;
            _isDownloaded = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🗑️ PDF local supprimé'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Erreur suppression fichier: $e');
    }
  }

  Future<void> _saveProgress() async {
    if (_startTime == null) return;

    final endTime = DateTime.now();
    final timeSpent = endTime.difference(_startTime!).inSeconds;

    print('📄 PDF viewed: ${widget.resource.title}');
    print('⏱️ Time spent: $timeSpent seconds');
    print('📖 Pages viewed: $_currentPage / $_totalPages');

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    // Update progress with time spent
    await courseProvider.updateProgressWithUUID(
      userId: widget.userId,
      courseId: widget.courseId,
      currentResourceId: widget.resource.id,
      additionalTimeSpentSeconds: timeSpent,
    );
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
    });
    print('📚 PDF loaded: $_totalPages pages');
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber;
    });
  }

  Future<void> _downloadPdf() async {
    try {
      final url = widget.resource.url!;
      final uri = Uri.parse(url);
      
      // Try to launch the URL for download
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in browser for download
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📥 Téléchargement démarré dans le navigateur'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Impossible d\'ouvrir le lien');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur de téléchargement: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPageSelector() {
    final controller = TextEditingController(text: _currentPage.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aller à la page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Numéro de page (1-$_totalPages)',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                _pdfController.jumpToPage(page);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Page invalide (1-$_totalPages)'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Aller'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _saveProgress(); // Save progress when leaving
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.title),
        actions: [
          // Local storage actions
          if (_isDownloaded) ...[
            // Already downloaded - show delete option
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer le fichier local',
              onPressed: _deleteLocalFile,
            ),
            IconButton(
              icon: const Icon(Icons.offline_pin),
              tooltip: 'Disponible hors ligne',
              onPressed: null, // Just indicator
            ),
          ] else ...[
            // Not downloaded - show download to local option
            IconButton(
              icon: const Icon(Icons.download_for_offline),
              tooltip: 'Télécharger pour usage hors ligne',
              onPressed: _downloadToLocal,
            ),
          ],
          // Browser download button
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Ouvrir dans le navigateur',
            onPressed: _downloadPdf,
          ),
          if (_totalPages > 0) ...[
            // Page indicator
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // Go to page
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Aller à la page',
              onPressed: _showPageSelector,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Téléchargement en cours...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Retour'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildPdfViewer(),
      floatingActionButton: _totalPages > 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Previous page
                if (_currentPage > 1)
                  FloatingActionButton.small(
                    heroTag: 'prevPage',
                    onPressed: () => _pdfController.previousPage(),
                    child: const Icon(Icons.keyboard_arrow_up),
                  ),
                const SizedBox(height: 8),
                // Next page
                if (_currentPage < _totalPages)
                  FloatingActionButton.small(
                    heroTag: 'nextPage',
                    onPressed: () => _pdfController.nextPage(),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
              ],
            )
          : null,
      bottomNavigationBar: widget.resource.description != null
          ? Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.resource.description!,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
    );
  }

  /// Build PDF viewer widget (uses local file if available, otherwise network)
  Widget _buildPdfViewer() {
    if (_isDownloaded && _localFilePath != null) {
      // Use local file
      print('📱 Utilisation du fichier local: $_localFilePath');
      return SfPdfViewer.file(
        File(_localFilePath!),
        key: _pdfViewerKey,
        controller: _pdfController,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _errorMessage = 'Erreur de chargement: ${details.error}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${details.description}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } else {
      // Use network URL
      print('🌐 Chargement depuis le réseau: ${widget.resource.url}');
      return SfPdfViewer.network(
        widget.resource.url!,
        key: _pdfViewerKey,
        controller: _pdfController,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _errorMessage = 'Erreur de chargement: ${details.error}';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${details.description}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }
}
