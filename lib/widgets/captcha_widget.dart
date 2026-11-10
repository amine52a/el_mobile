import 'package:flutter/material.dart';
import 'dart:math';

/// Widget CAPTCHA pour validation anti-bot
/// Génère une opération mathématique simple que l'utilisateur doit résoudre
class CaptchaWidget extends StatefulWidget {
  final Function(bool) onValidationChanged;
  final VoidCallback? onRefresh;

  const CaptchaWidget({
    super.key,
    required this.onValidationChanged,
    this.onRefresh,
  });

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  final TextEditingController _controller = TextEditingController();
  late int _number1;
  late int _number2;
  late String _operator;
  late int _correctAnswer;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
    _controller.addListener(_validateAnswer);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateAnswer);
    _controller.dispose();
    super.dispose();
  }

  /// Génère une nouvelle question CAPTCHA
  void _generateCaptcha() {
    final random = Random();
    _number1 = random.nextInt(10) + 1; // 1-10
    _number2 = random.nextInt(10) + 1; // 1-10

    // Choisir aléatoirement entre addition et soustraction
    final operations = ['+', '-'];
    _operator = operations[random.nextInt(operations.length)];

    // Calculer la bonne réponse
    if (_operator == '+') {
      _correctAnswer = _number1 + _number2;
    } else {
      // S'assurer que le résultat est positif pour la soustraction
      if (_number1 < _number2) {
        final temp = _number1;
        _number1 = _number2;
        _number2 = temp;
      }
      _correctAnswer = _number1 - _number2;
    }

    setState(() {
      _isValid = false;
    });
  }

  /// Valide la réponse de l'utilisateur
  void _validateAnswer() {
    final userAnswer = int.tryParse(_controller.text);
    final isValid = userAnswer == _correctAnswer;

    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
      widget.onValidationChanged(isValid);
    }
  }

  /// Rafraîchit le CAPTCHA
  void _refresh() {
    _controller.clear();
    _generateCaptcha();
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isValid ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône et titre
          Row(
            children: [
              Icon(
                Icons.security,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Vérification de sécurité',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              // Bouton rafraîchir
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _refresh,
                tooltip: 'Nouvelle question',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question mathématique
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Combien font ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '$_number1 $_operator $_number2',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  ' ?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Champ de réponse
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Votre réponse',
                    hintText: 'Entrez le résultat',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      _isValid ? Icons.check_circle : Icons.edit,
                      color: _isValid ? Colors.green : Colors.grey,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => _controller.clear(),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),

          // Indication de validation
          if (_controller.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isValid ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: _isValid ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _isValid ? 'Correct !' : 'Réponse incorrecte',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
