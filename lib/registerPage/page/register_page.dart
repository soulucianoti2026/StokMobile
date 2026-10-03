import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stokmobile/loginpage/page/login_page.dart';
import 'package:stokmobile/registerPage/controllers/controller.dart';
import 'package:stokmobile/shared/app_colors.dart';
import 'package:stokmobile/shared/widgets/app_elavated_button.dart';
import 'package:stokmobile/shared/mocks/mock_users.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    this.controller,
    this.onProfileSaved,
    this.onAccountDeleted,
  });
  final RegisterController? controller;
  final ValueChanged<UsersMock>? onProfileSaved;
  final VoidCallback? onAccountDeleted;
  static const route = '/cadastro';
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final _controller = widget.controller ?? RegisterController();
  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Widget _icon(String name, [double size = 18]) => name.startsWith('camera')
      ? Image.asset(
          'assets/images/register/$name.png',
          width: size,
          height: size,
          excludeFromSemantics: true,
        )
      : SvgPicture.asset(
          'assets/images/register/$name.svg',
          width: size,
          height: size,
          excludeFromSemantics: true,
        );

  void _back() {
    if (_controller.isLoading) return;
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.route);
    }
  }

  Future<void> _submit() async {
    final success = await _controller.submit();
    if (!mounted || !success) return;
    if (_controller.isEditing) {
      widget.onProfileSaved?.call(_controller.savedUser!);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta cadastrada! Entre com seu e-mail e senha.'),
      ),
    );
    _back();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir minha conta'),
        content: const Text(
          'Tem certeza de que deseja excluir sua conta? '
          'Seus dados de perfil e sua foto serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (await _controller.deleteAccount() && mounted) {
      widget.onAccountDeleted?.call();
    }
  }

  Widget _photoOption(
    String label,
    String icon,
    ImageSource source, {
    bool primary = false,
  }) => Expanded(
    child: Material(
      color: primary ? AppColors.teal600 : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _controller.isLoading || _controller.isPickingPhoto
            ? null
            : () => _controller.pickPhoto(source),
        child: Container(
          padding: EdgeInsets.all(primary ? 12 : 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: primary ? null : Border.all(color: AppColors.slate200),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.slate50,
                  shape: BoxShape.circle,
                  border: primary
                      ? null
                      : Border.all(color: AppColors.slate200),
                ),
                child: _icon(icon),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 16 / 13,
                  fontWeight: FontWeight.w600,
                  color: primary ? AppColors.white : AppColors.slate950,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _photoSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Foto do usuário',
        style: TextStyle(
          fontSize: 13,
          height: 16 / 13,
          fontWeight: FontWeight.w600,
          color: AppColors.slate600,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        height: 120,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.slate200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _controller.isPickingPhoto
            ? const Center(child: CircularProgressIndicator())
            : _controller.photoBytes != null
            ? Image.memory(
                _controller.photoBytes!,
                fit: BoxFit.contain,
                semanticLabel: 'Prévia da foto do usuário',
                errorBuilder: (_, _, _) => const Center(
                  child: Text('Não foi possível exibir esta foto.'),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.teal600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowTeal60020,
                          offset: const Offset(0, 8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: _icon('camera_preview', 22),
                  ),
                  Text(
                    'Nenhuma foto adicionada',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _photoOption(
            'Adicionar foto existente',
            'gallery',
            ImageSource.gallery,
          ),
          const SizedBox(width: 12),
          _photoOption(
            'Tirar foto com a câmera',
            'camera',
            ImageSource.camera,
            primary: true,
          ),
        ],
      ),
    ],
  );

  Widget _field(
    String label,
    String hint,
    String icon,
    TextEditingController field,
    String? Function(String?) validator, {
    bool secret = false,
    bool visible = false,
    VoidCallback? toggle,
    TextInputType? keyboard,
    bool last = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            height: 16 / 13,
            fontWeight: FontWeight.w600,
            color: AppColors.slate600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: field,
          validator: validator,
          obscureText: secret && !visible,
          keyboardType: keyboard,
          textInputAction: last ? TextInputAction.done : TextInputAction.next,
          textCapitalization: field == _controller.name
              ? TextCapitalization.words
              : TextCapitalization.none,
          autocorrect: !secret,
          enableSuggestions: !secret,
          onFieldSubmitted: last ? (_) => _submit() : null,
          style: TextStyle(
            fontSize: 14,
            height: 1.2,
            letterSpacing: 0,
            color: AppColors.slate950,
          ),
          decoration: InputDecoration(
            constraints: const BoxConstraints(minHeight: 48),
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: AppColors.slate600),
            filled: true,
            fillColor: AppColors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: _icon(icon),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 18,
            ),
            suffixIconConstraints: const BoxConstraints(
              minHeight: 46,
              minWidth: 48,
            ),
            suffixIcon: secret
                ? IconButton(
                    tooltip: visible ? 'Ocultar $label' : 'Mostrar $label',
                    onPressed: toggle,
                    icon: visible
                        ? Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.slate400,
                          )
                        : _icon('eye_off'),
                  )
                : null,
            errorMaxLines: 3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.teal600),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Inter'),
    ),
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => PopScope(
              canPop: !_controller.isLoading,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                  onPressed: _controller.isLoading
                                      ? null
                                      : _back,
                                  tooltip: _controller.isEditing
                                      ? 'Voltar'
                                      : 'Voltar ao login',
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: AppColors.slate200,
                                      ),
                                    ),
                                  ),
                                  icon: _icon('back'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.teal600,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowTeal60020,
                                      offset: const Offset(0, 8),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: _icon('package', 30),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _controller.isEditing
                                  ? 'Editar perfil'
                                  : 'Criar conta',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                height: 34 / 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.slate950,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 320,
                                ),
                                child: Text(
                                  _controller.isEditing
                                      ? 'Atualize seus dados e sua foto de perfil no StockMobile.'
                                      : 'Preencha seus dados para começar a usar o StockMobile.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.45,
                                    color: AppColors.slate600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Form(
                              key: _controller.formKey,
                              child: Column(
                                children: [
                                  _field(
                                    'Nome Completo',
                                    'Digite seu nome completo',
                                    'user',
                                    _controller.name,
                                    _controller.validateName,
                                  ),
                                  _field(
                                    'Email',
                                    'exemplo@empresa.com',
                                    'email',
                                    _controller.email,
                                    _controller.validateEmail,
                                    keyboard: TextInputType.emailAddress,
                                  ),
                                  _field(
                                    'CPF/Identidade',
                                    'Digite seu CPF ou identidade',
                                    'identity',
                                    _controller.document,
                                    _controller.validateDocument,
                                  ),
                                  _field(
                                    'Senha',
                                    _controller.isEditing
                                        ? 'Digite uma nova senha'
                                        : 'Crie uma senha',
                                    'lock',
                                    _controller.password,
                                    _controller.validatePassword,
                                    secret: true,
                                    visible: _controller.passwordVisible,
                                    toggle: _controller.togglePassword,
                                  ),
                                  _field(
                                    'Repetir a senha',
                                    _controller.isEditing
                                        ? 'Digite a nova senha novamente'
                                        : 'Digite a senha novamente',
                                    'lock',
                                    _controller.confirmation,
                                    _controller.validateConfirmation,
                                    secret: true,
                                    visible: _controller.confirmationVisible,
                                    toggle: _controller.toggleConfirmation,
                                    last: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _photoSection(),
                            const SizedBox(height: 20),
                            if (_controller.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    _controller.error!,
                                    style: TextStyle(color: AppColors.red500),
                                  ),
                                ),
                              ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowTeal60013,
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: AppElevatedButton(
                                onPressed: _controller.isPickingPhoto
                                    ? null
                                    : _submit,
                                isLoading: _controller.isLoading,
                                label: _controller.isEditing
                                    ? 'Salvar alterações'
                                    : 'Cadastrar',
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_controller.isEditing)
                              SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed:
                                      _controller.isLoading ||
                                          _controller.isPickingPhoto
                                      ? null
                                      : _deleteAccount,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.red50,
                                    foregroundColor: const Color(0xFFDC2626),
                                    side: BorderSide(color: AppColors.red200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _icon('trash'),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Autoexclusão',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Já tem uma conta?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _back,
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 16),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Voltar para o login',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.teal600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Column(
                            children: [
                              Text(
                                'Desenvolvido por StockMobile LTDA',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.slate400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'v2.4.1',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.slate400,
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
    ),
  );
}
