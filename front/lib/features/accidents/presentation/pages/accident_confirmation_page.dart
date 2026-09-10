import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart' show AppRoutes;
import '../../../../core/logging/app_logger.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/accident_event_providers.dart';

/// Pantalla dedicada de "¿estás bien?" — a pantalla completa, alcanzada
/// solo al tocar el aviso de un posible accidente (ver
/// `accident_alert_response.dart`), nunca por navegación normal.
///
/// Pedido explícito en vivo: antes, tocar "Estoy bien" en la notificación
/// (cuando de verdad hacía algo) cancelaba el aviso en silencio, sin
/// ninguna pantalla propia ni segunda confirmación — y no había ninguna
/// forma de decir "no estoy bien del todo, pero tampoco es una emergencia
/// clara — mandá igual la alerta ya, no esperes el cronómetro". Ahora hay
/// dos acciones, cada una con su propio peso visual:
///  - **Sí, estoy bien** → cancela el aviso (mismo `cancel()` de siempre).
///  - **Necesito ayuda** → confirma YA, sin esperar el resto del
///    cronómetro (mismo `confirm()` que dispara el auto-confirmado al
///    vencer el tiempo — la única diferencia es que acá lo dispara la
///    propia persona, antes de tiempo, a propósito).
class AccidentConfirmationPage extends ConsumerStatefulWidget {
  const AccidentConfirmationPage({required this.accidentEventId, super.key});

  final String accidentEventId;

  @override
  ConsumerState<AccidentConfirmationPage> createState() =>
      _AccidentConfirmationPageState();
}

enum _Resolution { none, cancelled, confirmed }

class _AccidentConfirmationPageState
    extends ConsumerState<AccidentConfirmationPage> {
  bool _isSubmitting = false;
  _Resolution _resolution = _Resolution.none;
  String? _error;

  Future<void> _resolve({required bool imOk}) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      final repository = ref.read(accidentEventRepositoryProvider);
      if (imOk) {
        await repository.cancel(widget.accidentEventId);
      } else {
        await repository.confirm(widget.accidentEventId);
      }
      if (!mounted) return;
      setState(() {
        _resolution = imOk ? _Resolution.cancelled : _Resolution.confirmed;
      });
    } catch (error, stackTrace) {
      AppLogger.error(
        'AccidentConfirmationPage: failed to resolve',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goHome() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Mientras no se resolvió nada, no se puede salir con el botón
      // atrás sin querer — es justo la pantalla que no debería poder
      // ignorarse por accidente.
      canPop: _resolution != _Resolution.none,
      child: Scaffold(
        backgroundColor: AppTheme.carbon,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: switch (_resolution) {
              _Resolution.none => _QuestionView(
                isSubmitting: _isSubmitting,
                error: _error,
                onImOk: () => _resolve(imOk: true),
                onNeedHelp: () => _resolve(imOk: false),
              ),
              _Resolution.cancelled => _ResultView(
                icon: Icons.check_circle_outline,
                color: AppTheme.accent,
                title: 'Aviso cancelado',
                message: 'Le avisamos a tu grupo que estás bien.',
                onDone: _goHome,
              ),
              _Resolution.confirmed => _ResultView(
                icon: Icons.campaign_outlined,
                color: AppTheme.sos,
                title: 'Alerta enviada',
                message:
                    'Avisamos a tu grupo y a tus contactos de emergencia con '
                    'tu ubicación.',
                onDone: _goHome,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.isSubmitting,
    required this.error,
    required this.onImOk,
    required this.onNeedHelp,
  });

  final bool isSubmitting;
  final String? error;
  final VoidCallback onImOk;
  final VoidCallback onNeedHelp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppTheme.sos.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.sos.withValues(alpha: 0.6)),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: AppTheme.sos,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          '¿Estás bien?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Sentinel detectó un posible accidente. Contanos qué pasó.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
        const Spacer(),
        if (error != null) ...[
          Text(
            error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.sos),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        // Botones grandes a propósito — pedido explícito en vivo ("que el
        // botón sea más grande"): esta es la pantalla que reemplaza al
        // botón chico de la notificación, así que acá sí hay espacio de
        // sobra para hacerlo imposible de tocar por error.
        SizedBox(
          width: double.infinity,
          height: 72,
          child: FilledButton(
            onPressed: isSubmitting ? null : onImOk,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accent,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Text('SÍ, ESTOY BIEN'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 72,
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onNeedHelp,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppTheme.sos,
              foregroundColor: Colors.white,
              side: BorderSide.none,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('NECESITO AYUDA — AVISAR AHORA'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Si no tocás nada, la alerta se manda sola al vencer el tiempo.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.onDone,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 72, color: color),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: onDone, child: const Text('Listo')),
        ),
      ],
    );
  }
}
