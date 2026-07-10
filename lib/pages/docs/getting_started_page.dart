import 'package:flutter/material.dart';

import '../../components/markdown_renderer.dart';
import '../../services/docs_loader.dart';
import '../../theme/arcade_theme.dart';

class GettingStartedPage extends StatelessWidget {
  const GettingStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Getting Started - Flutter Arcade UI',
      color: ArcadeColors.violet,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width < 700 ? 20 : 42,
            vertical: 40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: MarkdownRenderer(
                markdown: DocsLoader.read('getting-started'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
