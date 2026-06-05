import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/supabase_config.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  
  // Par défaut sur la vue responsable
  bool _isResponsableLogin = true;
  bool _isAdminUnlocked = false; // Le formulaire admin est-il débloqué ?
  final _secretCodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secretCodeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        final authService = AuthService();
        final userId = response.user!.id;
        
        final isAdmin = await authService.isAdmin(userId);

        if (_isResponsableLogin) {
          if (isAdmin) {
             await authService.signOut();
             if (mounted) {
               setState(() {
                 _errorMessage = 'Email ou mot de passe incorrect.';
                 _isLoading = false;
               });
             }
             return;
          }
        } else {
          if (!isAdmin) {
             await authService.signOut();
             if (mounted) {
               setState(() {
                 _errorMessage = 'Accès refusé. Vous n\'avez pas les droits d\'administrateur.';
                 _isLoading = false;
               });
             }
             return;
          }
        }

        if (mounted) {
          // L'écran /home gérera la redirection finale vers /dashboard ou /responsable
          await _animationController.reverse().then((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
        }
      } else {
        setState(() {
          _errorMessage = _isResponsableLogin 
              ? 'Email ou mot de passe incorrect.' 
              : 'Erreur de connexion. Veuillez réessayer.';
          _isLoading = false;
        });
      }
    } on AuthException catch (error) {
      setState(() {
        _errorMessage = _isResponsableLogin 
            ? 'Email ou mot de passe incorrect.' 
            : error.message;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = _isResponsableLogin 
            ? 'Email ou mot de passe incorrect.' 
            : 'Une erreur inattendue est survenue.';
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.poppins(
        color: AppTheme.darkColor.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.poppins(
        color: AppTheme.greyColor.withOpacity(0.5),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        borderSide: BorderSide(color: AppTheme.greyColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        borderSide: BorderSide(color: AppTheme.greyColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        borderSide: BorderSide(color: AppTheme.dangerColor, width: 1),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.backgroundColor,
              AppTheme.secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadius * 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.03),
                        spreadRadius: 10,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildRoleToggle(),
                        const SizedBox(height: 32),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _isResponsableLogin || _isAdminUnlocked
                              ? Container(
                                  key: const ValueKey('login_form'),
                                  child: _buildLoginForm(),
                                )
                              : Container(
                                  key: const ValueKey('secret_form'),
                                  child: _buildSecretCodeForm(),
                                ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 24),
                          _buildErrorMessage()
                              .animate()
                              .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
                              .slideY(
                                begin: 0.5,
                                end: 0,
                                duration: 300.ms,
                                curve: Curves.easeInOut,
                              ),
                        ],
                        const SizedBox(height: 24),
                        _buildFooter(),
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

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius * 1.5),
        border: Border.all(color: AppTheme.greyColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleButton('Responsable', true),
          ),
          Expanded(
            child: _buildRoleButton('Administrateur', false),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildRoleButton(String title, bool isResponsable) {
    final isSelected = _isResponsableLogin == isResponsable;
    return GestureDetector(
      onTap: () {
        if (_isResponsableLogin != isResponsable) {
          setState(() {
            _isResponsableLogin = isResponsable;
            _errorMessage = null; // Réinitialiser les erreurs lors du changement
            // On peut verrouiller à nouveau le form admin quand on le quitte si souhaité,
            // ou le laisser déverrouillé pour la session. On le laisse déverrouillé pour l'instant.
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : AppTheme.darkColor.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'logo',
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Container(
              key: ValueKey<bool>(_isResponsableLogin),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isResponsableLogin 
                    ? AppTheme.secondaryColor.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _isResponsableLogin
                        ? AppTheme.secondaryColor.withOpacity(0.2)
                        : AppTheme.primaryColor.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isResponsableLogin ? Icons.build_circle_rounded : Icons.admin_panel_settings_rounded,
                size: 60,
                color: _isResponsableLogin ? AppTheme.secondaryColor : AppTheme.primaryColor,
              ),
            ),
          ).animate().scale(
            duration: 600.ms,
            delay: 200.ms,
            curve: Curves.easeOutBack,
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _isResponsableLogin ? 'Espace Responsable' : 'CARHABTI Admin',
            key: ValueKey<bool>(_isResponsableLogin),
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppTheme.darkColor,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _isResponsableLogin 
                ? 'Connectez-vous pour gérer votre garage'
                : 'Connectez-vous pour accéder au tableau de bord',
            key: ValueKey<bool>(_isResponsableLogin),
            style: GoogleFonts.poppins(
              color: AppTheme.greyColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildSecretCodeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.lock_person_rounded,
          size: 48,
          color: AppTheme.primaryColor.withOpacity(0.8),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          'Accès restreint',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          'Veuillez saisir le code secret pour afficher la connexion administrateur.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.greyColor,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
        TextField(
          controller: _secretCodeController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: GoogleFonts.poppins(
            fontSize: 24,
            letterSpacing: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkColor,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            counterText: '',
            hintText: '••••',
            hintStyle: GoogleFonts.poppins(
              color: AppTheme.greyColor.withOpacity(0.5),
              letterSpacing: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide(color: AppTheme.greyColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide(color: AppTheme.greyColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value == '0123') {
              setState(() {
                _isAdminUnlocked = true;
                _secretCodeController.clear();
                _errorMessage = null;
              });
            } else if (value.length == 4) {
              setState(() {
                _errorMessage = 'Code secret invalide.';
              });
            } else {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            }
          },
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: TextFormField(
              key: const ValueKey('email_field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.darkColor,
              ),
              decoration: _buildInputDecoration(
                label: 'Email',
                hint: 'Entrez votre adresse email',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre adresse email';
                }
                if (!RegExp(
                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                ).hasMatch(value)) {
                  return 'Veuillez entrer une adresse email valide';
                }
                return null;
              },
            ),
          )
          .animate()
          .fadeIn(delay: 800.ms, duration: 500.ms)
          .slideX(
            begin: 0.1,
            end: 0,
            delay: 800.ms,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: TextFormField(
              key: const ValueKey('password_field'),
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.darkColor,
              ),
              decoration: _buildInputDecoration(
                label: 'Mot de passe',
                hint: 'Entrez votre mot de passe',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre mot de passe';
                }
                if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
                return null;
              },
            ),
          )
          .animate()
          .fadeIn(delay: 1000.ms, duration: 500.ms)
          .slideX(
            begin: 0.1,
            end: 0,
            delay: 1000.ms,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? true;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Se souvenir de moi',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.darkColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                ),
                child: Text(
                  'Mot de passe oublié?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isResponsableLogin ? AppTheme.secondaryColor : AppTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.primaryColor.withOpacity(
                0.6,
              ),
              elevation: 0,
              shadowColor: AppTheme.primaryColor.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppTheme.greyColor.withOpacity(0.5);
                  }
                  return _isResponsableLogin ? AppTheme.secondaryColor : AppTheme.primaryColor;
                },
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _isResponsableLogin ? 'Connexion Responsable' : 'Connexion Administrateur',
                          key: ValueKey<bool>(_isResponsableLogin),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
          )
          .animate()
          .fadeIn(delay: 1400.ms, duration: 500.ms)
          .scaleXY(
            begin: 0.95,
            end: 1,
            delay: 1400.ms,
            duration: 600.ms,
            curve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.dangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.dangerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.dangerColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                color: AppTheme.dangerColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Vous n\'avez pas de compte?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.darkColor.withOpacity(0.7),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Veuillez contacter l\'administrateur pour créer un compte.',
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
            child: Text(
              'Contactez l\'administrateur',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1600.ms, duration: 500.ms);
  }
}
