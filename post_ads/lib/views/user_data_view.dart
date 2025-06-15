import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:post_ads/config/config.dart';
import 'package:post_ads/models/usuario.dart';
import 'package:post_ads/services/session_manager.dart';
import 'package:post_ads/services/usuario_service.dart';
import 'package:post_ads/utils/get_styles.dart';

class UserDataView extends StatefulWidget {
  const UserDataView({super.key});

  @override
  State<UserDataView> createState() => _UserDataViewState();
}

class _UserDataViewState extends State<UserDataView> {
  Usuario? usuario;
  File? _pickedImage;
  bool _isUploadingPhoto = false;

  @override
  Widget build(BuildContext context) {
    return _buildUserDataView();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsuario();
    });
  }

  Future<void> _loadUsuario() async {
    final u = await SessionManager.getUsuario();
    if (u == null) return;
    final usuarioService = UsuarioService();
    final usuarioCompleto = await usuarioService.fetchUsuarioById(u.idUsuario);
    setState(() {
      usuario = usuarioCompleto;
    });
  }

  Future<void> _showEditPhotoBottomSheet(Usuario user) async {
    Future<void> _pickAndCropImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar imagen',
              toolbarColor: Colors.indigo,
              toolbarWidgetColor: Colors.white,
              hideBottomControls: true,
            ),
            IOSUiSettings(title: 'Recortar imagen'),
          ],
        );
        if (croppedFile != null) {
          _pickedImage = File(croppedFile.path);
        }
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => Padding(
                padding: EdgeInsets.only(
                  top: 32,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.55,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              // Imagen de perfil con botón de editar
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.indigo.shade50,
                                    radius: 100,
                                    backgroundImage:
                                        _pickedImage != null
                                            ? FileImage(_pickedImage!)
                                            : (user.fotoUsuario != null &&
                                                user.fotoUsuario!.isNotEmpty)
                                            ? NetworkImage(
                                              '$apiBaseUrl${user.fotoUsuario!}',
                                            )
                                            : null,
                                    child:
                                        (user.fotoUsuario == null ||
                                                    user
                                                        .fotoUsuario!
                                                        .isEmpty) &&
                                                _pickedImage == null
                                            ? Icon(
                                              Icons.person,
                                              color: Colors.indigo,
                                              size: 160,
                                            )
                                            : null,
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: InkWell(
                                      onTap: () async {
                                        await _pickAndCropImage();
                                        setModalState(() {});
                                      },
                                      customBorder: const CircleBorder(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                icon:
                                    _isUploadingPhoto
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Icon(
                                          Icons.save,
                                          color: Colors.white,
                                        ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                label: Text(
                                  _isUploadingPhoto
                                      ? 'Guardando...'
                                      : 'Guardar',
                                ),
                                onPressed:
                                    _pickedImage == null
                                        ? null
                                        : () async {
                                          setModalState(() {
                                            _isUploadingPhoto = true;
                                          });
                                          await _actualizarFotoPerfil(
                                            user.idUsuario,
                                            _pickedImage!,
                                          );
                                          setModalState(() {
                                            _isUploadingPhoto = false;
                                          });
                                        },
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextButton(
                            onPressed:
                                _isUploadingPhoto
                                    ? null
                                    : () => Navigator.pop(context),
                            child: const Text(
                              'Cerrar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  Future<void> _actualizarFotoPerfil(int idUsuario, File foto) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    final usuarioService = UsuarioService();
    final mensaje = await usuarioService.updateProfilePhoto(idUsuario, foto);

    setState(() {
      _isUploadingPhoto = false;
    });

    if (mensaje != null) {
      await _loadUsuario();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar la foto'),
            backgroundColor: Colors.red, // Error: rojo
          ),
        );
      }
    }
  }

  Future<void> _cambiarContrasena({
    required int idUsuario,
    required String actual,
    required String nueva,
    required void Function(bool) setLoading,
  }) async {
    setLoading(true);
    final usuarioService = UsuarioService();
    final result = await usuarioService.changePassword(
      idUsuario: idUsuario,
      nuevaPassword: nueva,
      actualPassword: actual,
    );
    setLoading(false);

    if (mounted) {
      if (result['success']) {
        Navigator.pop(context);
        await SessionManager.clear(); // Cierra la sesión
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        ); // Navega al login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Contraseña cambiada correctamente.',
            ),
            backgroundColor: Colors.green, // Éxito: verde
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'No se pudo cambiar la contraseña.',
            ),
            backgroundColor: Colors.red, // Error: rojo
          ),
        );
      }
    }
  }

  Future<void> _actualizarDatosPersonales({
    required int idUsuario,
    required String nombre,
    required String apellido,
    required void Function(bool) setLoading,
  }) async {
    setLoading(true);
    final usuarioService = UsuarioService();
    final result = await usuarioService.updatePersonalData(
      idUsuario: idUsuario,
      nomUsuario: nombre,
      apeUsuario: apellido,
    );
    setLoading(false);

    if (mounted) {
      if (result['success']) {
        await _loadUsuario();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Datos personales actualizados correctamente.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'No se pudieron actualizar los datos personales.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _actualizarUserNameYEmail({
    required int idUsuario,
    required String userName,
    required String email,
    required void Function(bool) setLoading,
  }) async {
    setLoading(true);
    final usuarioService = UsuarioService();
    final result = await usuarioService.updateUserNameAndEmail(
      idUsuario: idUsuario,
      userName: userName,
      emailUsuario: email,
    );
    setLoading(false);

    if (mounted) {
      if (result['success']) {
        await _loadUsuario();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Usuario y correo modificados correctamente.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'No se pudo modificar usuario y correo.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verificarCodigoCorreo({
    required String emailUsuario,
    required String codigo,
    required void Function(bool) setLoading,
  }) async {
    setLoading(true);
    final usuarioService = UsuarioService();
    final result = await usuarioService.verifyEmailCode(
      emailUsuario: emailUsuario,
      codigo: codigo,
    );
    setLoading(false);

    if (mounted) {
      if (result['success']) {
        await _loadUsuario();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Correo verificado correctamente.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'No se pudo verificar el correo.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarCuenta(int idUsuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );
    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    final usuarioService = UsuarioService();
    final result = await usuarioService.deactivateUser(idUsuario);
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Operación realizada'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (result['success'] == true) {
      await SessionManager.clear();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _showEditPersonalDataModal() async {
    final formKey = GlobalKey<FormState>();
    String nombre = usuario?.nomUsuario ?? '';
    String apellido = usuario?.apeUsuario ?? '';
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => Padding(
                padding: EdgeInsets.only(
                  top: 32,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Editar datos personales',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TextFormField(
                                initialValue: nombre,
                                decoration: const InputDecoration(
                                  labelText: 'Nombres',
                                  border: OutlineInputBorder(),
                                ),
                                textCapitalization: TextCapitalization.words,
                                onChanged: (value) => nombre = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su nombre';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TextFormField(
                                initialValue: apellido,
                                decoration: const InputDecoration(
                                  labelText: 'Apellidos',
                                  border: OutlineInputBorder(),
                                ),
                                textCapitalization: TextCapitalization.words,
                                onChanged: (value) => apellido = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su apellido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    icon:
                                        isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.save,
                                              color: Colors.white,
                                            ),
                                    label: Text(
                                      isLoading ? 'Guardando...' : 'Guardar',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                _actualizarDatosPersonales(
                                                  idUsuario: usuario!.idUsuario,
                                                  nombre: nombre,
                                                  apellido: apellido,
                                                  setLoading:
                                                      (v) => setModalState(
                                                        () => isLoading = v,
                                                      ),
                                                );
                                              }
                                            },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                child: const Text(
                                  'Cerrar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  Future<void> _showEditUserNameAndEmailModal() async {
    final formKey = GlobalKey<FormState>();
    String userName = usuario?.userName ?? '';
    String email = usuario?.emailUsuario ?? '';
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => Padding(
                padding: EdgeInsets.only(
                  top: 32,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Editar usuario y correo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            if (usuario?.userName != null &&
                                (usuario?.userName ?? '').isNotEmpty) ...[
                              const SizedBox(height: 24),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: TextFormField(
                                  initialValue: userName,
                                  decoration: const InputDecoration(
                                    labelText: 'Usuario',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) => userName = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese su usuario';
                                    }
                                    if (value.length < 3) {
                                      return 'Mínimo 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TextFormField(
                                initialValue: email,
                                decoration: const InputDecoration(
                                  labelText: 'Correo electrónico',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) => email = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su correo';
                                  }
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(value)) {
                                    return 'Correo no válido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    icon:
                                        isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.save,
                                              color: Colors.white,
                                            ),
                                    label: Text(
                                      isLoading ? 'Guardando...' : 'Guardar',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                _actualizarUserNameYEmail(
                                                  idUsuario: usuario!.idUsuario,
                                                  userName: userName,
                                                  email: email,
                                                  setLoading:
                                                      (v) => setModalState(
                                                        () => isLoading = v,
                                                      ),
                                                );
                                              }
                                            },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                child: const Text(
                                  'Cerrar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  Future<void> _showVerifyEmailModal() async {
    final formKey = GlobalKey<FormState>();
    String code = '';
    bool isLoading = false;

    final usuarioService = UsuarioService();
    final sendResult = await usuarioService.sendRecoveryCode(
      usuario!.emailUsuario,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => Padding(
                padding: EdgeInsets.only(
                  top: 32,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.38,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Verificar correo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                'El código se envió al correo: ${maskEmail(usuario!.emailUsuario)}',
                                style: TextStyle(
                                  color:
                                      sendResult['success']
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Código de verificación',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => code = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el código';
                                  }
                                  if (value.length < 4) {
                                    return 'El código debe tener al menos 4 dígitos';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    icon:
                                        isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.verified,
                                              color: Colors.white,
                                            ),
                                    label: Text(
                                      isLoading
                                          ? 'Verificando...'
                                          : 'Verificar',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                _verificarCodigoCorreo(
                                                  emailUsuario:
                                                      usuario!.emailUsuario,
                                                  codigo: code,
                                                  setLoading:
                                                      (v) => setModalState(
                                                        () => isLoading = v,
                                                      ),
                                                );
                                              }
                                            },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                child: const Text(
                                  'Cerrar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  Future<void> _showChangePasswordModal() async {
    final formKey = GlobalKey<FormState>();
    String currentPassword = '';
    String newPassword = '';
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) => Padding(
                padding: EdgeInsets.only(
                  top: 32,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.55,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).toInt()),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Cambiar contraseña',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Campo contraseña actual
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TextFormField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Contraseña actual',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => currentPassword = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese su contraseña actual';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Campo nueva contraseña
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TextFormField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Nueva contraseña',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => newPassword = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la nueva contraseña';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Campo confirmar contraseña
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: TextFormField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Confirmar contraseña',
                                  border: OutlineInputBorder(),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirme la contraseña';
                                  }
                                  if (value != newPassword) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    icon:
                                        isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(
                                              Icons.save,
                                              color: Colors.white,
                                            ),
                                    label: Text(
                                      isLoading ? 'Guardando...' : 'Guardar',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed:
                                        isLoading
                                            ? null
                                            : () {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                _cambiarContrasena(
                                                  idUsuario: usuario!.idUsuario,
                                                  actual: currentPassword,
                                                  nueva: newPassword,
                                                  setLoading:
                                                      (v) => setModalState(
                                                        () => isLoading = v,
                                                      ),
                                                );
                                              }
                                            },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                child: const Text(
                                  'Cerrar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  Widget _buildUserDataView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body:
          usuario == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          radius: 80,
                          backgroundImage:
                              (usuario!.fotoUsuario != null &&
                                      usuario!.fotoUsuario!.isNotEmpty)
                                  ? NetworkImage(
                                    '$apiBaseUrl${usuario!.fotoUsuario}',
                                  )
                                  : null,
                          child:
                              (usuario!.fotoUsuario == null ||
                                      usuario!.fotoUsuario!.isEmpty)
                                  ? Icon(
                                    Icons.person,
                                    color: Colors.indigo,
                                    size: 120,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              _showEditPhotoBottomSheet(usuario!);
                            },
                            customBorder: const CircleBorder(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.edit, color: Colors.indigo),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${usuario!.nomUsuario} ${usuario!.apeUsuario ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    if (usuario!.userName != null &&
                        usuario!.userName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '@${usuario!.userName}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.indigo),
                      title: const Text('Datos personales'),
                      onTap: () {
                        _showEditPersonalDataModal();
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.alternate_email,
                        color: Colors.deepPurple,
                      ),
                      title: const Text('Datos de acceso'),
                      onTap: () {
                        _showEditUserNameAndEmailModal();
                      },
                    ),
                    if (usuario!.emailVerified == false)
                      ListTile(
                        leading: const Icon(
                          Icons.verified_outlined,
                          color: Colors.orange,
                        ),
                        title: const Text('Verificar correo'),
                        onTap: () {
                          _showVerifyEmailModal();
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: Colors.teal),
                      title: const Text('Cambiar contraseña'),
                      onTap: () {
                        _showChangePasswordModal();
                      },
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Zona peligrosa',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Eliminar cuenta'),
                      onTap: () {
                        _eliminarCuenta(usuario!.idUsuario);
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
