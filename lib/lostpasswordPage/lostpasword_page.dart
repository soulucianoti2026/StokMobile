import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/lostpassword/controllers/lostpassword_controller.dart';

const _recoveryTeal = Color(0xFF2E9489);

class LostpaswordPage extends StatelessWidget {
  const LostpaswordPage({super.key, this.sendInstructions});

  static const String route = '/lost-password';
  final Future<void> Function(String email)? sendInstructions;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LostpasswordController(sendInstructions: sendInstructions),
      child: const _LostpasswordView(),
    );
  }
}

class _LostpasswordView extends StatelessWidget {
  const _LostpasswordView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LostpasswordController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Align(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 402,
                      minHeight: constraints.maxHeight,
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton.outlined(
                                tooltip: 'Voltar para o login',
                                onPressed: () =>
                                    controller.backToLogin(context),
                                style: IconButton.styleFrom(
                                  fixedSize: const Size(40, 40),
                                  foregroundColor: const Color(0xFF475569),
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_back, size: 18),
                                onLongPress: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const _RecoveryHeader(),
                            const _RecoveryForm(),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Column(
                            children: [
                              Text(
                                'Desenvolvido por StockMobile LTDA',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'v2.4.1',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryForm extends StatelessWidget {
  const _RecoveryForm();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LostpasswordController>();
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'E-mail corporativo',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.emailController,
            validator: controller.validateEmail,
            enabled: !controller.isLoading,
            onChanged: (_) => controller.clearMessage(),
            onFieldSubmitted: (_) => controller.submit(),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
            decoration: InputDecoration(
              isDense: true,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
              ),
              hintText: 'exemplo@empresa.com',
              prefixIcon: const Icon(
                Icons.mail_outline,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 48,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _recoveryTeal),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading ? null : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _recoveryTeal,
                foregroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shadowColor: const Color(0x552E9489),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: controller.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enviar instruções'),
            ),
          ),
          if (controller.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  controller.message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: controller.hasError
                        ? Theme.of(context).colorScheme.error
                        : const Color(0xFF0D9488),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Lembrou sua senha?',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => controller.backToLogin(context),
                child: const Text(
                  'Voltar para o login',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecoveryHeader extends StatelessWidget {
  const _RecoveryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 36),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _recoveryTeal,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330D9488),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: CustomPaint(
                size: Size(36, 36),
                painter: _PackageIconPainter(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recuperar senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 320,
            child: Text(
              'Informe seu e-mail corporativo para receber as instruções de redefinição.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageIconPainter extends CustomPainter {
  const _PackageIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.scale(size.width / 36, size.height / 36);
    canvas.drawPath(
      Path()
        ..moveTo(18, 3)
        ..lineTo(31.5, 10.5)
        ..lineTo(31.5, 25.5)
        ..lineTo(18, 33)
        ..lineTo(4.5, 25.5)
        ..lineTo(4.5, 10.5)
        ..close()
        ..moveTo(4.5, 10.5)
        ..lineTo(18, 18)
        ..lineTo(31.5, 10.5)
        ..moveTo(18, 18)
        ..lineTo(18, 33)
        ..moveTo(11.25, 6.75)
        ..lineTo(24.75, 14.25)
        ..lineTo(24.75, 21.75),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PackageIconPainter oldDelegate) => false;
}
