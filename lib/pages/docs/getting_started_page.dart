import 'package:flutter/material.dart';
import '../../components/markdown_renderer.dart';
import '../../services/docs_loader.dart';

/// Getting started page (/docs/getting-started)
class GettingStartedPage extends StatelessWidget {
  const GettingStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Getting Started - Flutter Arcade UI',
      color: Theme.of(context).primaryColor,
      child: Scaffold(
        body: FutureBuilder<String>(
          future: DocsLoader.loadMarkdown('getting-started'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading documentation: ${snapshot.error}'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: MarkdownRenderer(
                markdown:
                    snapshot.data ??
                    '# Getting Started\n\nDocumentation is being loaded...',
              ),
            );
          },
        ),
      ),
    );
  }
}
