import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/markdown_renderer.dart';
import '../../services/docs_loader.dart';

/// Documentation index page (/docs)
class DocsIndexPage extends StatelessWidget {
  const DocsIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arcade UI Documentation',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<String>(
        future: DocsLoader.loadMarkdown('index'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading documentation: ${snapshot.error}'),
            );
          }

          return MarkdownRenderer(
            markdown:
                snapshot.data ??
                '# Welcome to Arcade UI\n\nDocumentation is being loaded...',
          );
        },
      ),
    );
  }
}
