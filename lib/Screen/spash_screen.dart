import 'package:flutter/material.dart';
import 'package:oraculo/Screen/qr_scanner.dart';
import 'dart:async'; // Para as animações

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> with SingleTickerProviderStateMixin {
  // Controladores de animação
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controladores para animações do botão
  bool _isButtonHovered = false;
  bool _showQRAnimation = false;
  Timer? _qrAnimationTimer;

  @override
  void initState() {
    super.initState();
    
    // Configurar animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    // Iniciar a animação após um pequeno delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });
    
    // Configurar timer para mostrar a animação de QR Code
    _qrAnimationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _showQRAnimation = !_showQRAnimation;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _qrAnimationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1A2F), // Azul escuro do fundo do logo
              Color(0xFF102A44), // Azul intermediário
              Color(0xFF00E6FB), // Ciano do texto do logo
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Formas decorativas
              Positioned(
                top: -size.height * 0.1,
                left: -size.width * 0.2,
                child: Container(
                  height: size.width * 0.6,
                  width: size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.height * 0.05,
                right: -size.width * 0.2,
                child: Container(
                  height: size.width * 0.5,
                  width: size.width * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              
              // Conteúdo principal
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Column(
                    children: [
                      // Cabeçalho com indicador de versão
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "v1.0",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Ajuda",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Espaçador para centralizar logo
                      const Spacer(),
                      
                      // Logo e nome do app com animações
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                // Logo icon animado
                                SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Círculo de fundo
                                      Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF102A44).withOpacity(0.7),
                                        ),
                                      ),
                                      // Círculo menor
                                      Container(
                                        height: 110,
                                        width: 110,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF00E6FB).withOpacity(0.15),
                                        ),
                                      ),
                                      // Logo imagem
                                      Image.asset(
                                        'images/oraculo.png',
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Nome do app
                                // const Text(
                                //   "Oráculo",
                                //   style: TextStyle(
                                //     fontSize: 42,
                                //     fontWeight: FontWeight.w300,
                                //     color: Colors.white,
                                //     letterSpacing: 3,
                                //   ),
                                // ),
                                
                                // Tagline que explica o propósito do app
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    "Controle de Acesso Simplificado",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Ilustração contextual animada (QR Code)
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 600),
                            crossFadeState: _showQRAnimation 
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                            firstChild: Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.qr_code_scanner,
                                    color: const Color(0xFF2D7A7B),
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Escaneie para registrar",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                            secondChild: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.login,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      width: 20,
                                      height: 2,
                                      color: Colors.white24,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Controle de entrada e saída",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Botão de iniciar
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: GestureDetector(
                            onTap: () {
                              _navigateWithAnimation(context);
                            },
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! > 0) {
                                _navigateWithAnimation(context);
                              }
                            },
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return MouseRegion(
                                  onEnter: (_) => setState(() => _isButtonHovered = true),
                                  onExit: (_) => setState(() => _isButtonHovered = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: size.width,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(_isButtonHovered ? 0.2 : 0.1),
                                          blurRadius: _isButtonHovered ? 15 : 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Indicador de deslize
                                        Positioned(
                                          left: 20,
                                          top: 0,
                                          bottom: 0,
                                          child: AnimatedOpacity(
                                            duration: const Duration(milliseconds: 200),
                                            opacity: 0.8,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: const Color(0xFF2D7A7B).withOpacity(0.3),
                                                  size: 18,
                                                ),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: const Color(0xFF2D7A7B).withOpacity(0.5),
                                                  size: 18,
                                                ),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: const Color(0xFF2D7A7B).withOpacity(0.7),
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        // Texto e ícone principal
                                                            Center(
                                                              child: const Text(
                                                                "COMEÇAR AGORA",
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Color(0xFF2D7A7B),
                                                                  letterSpacing: 1.2,
                                                                ),
                                                              ),
                                                            ),
                                        
                                        // Círculo de ícone
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            height: 48,
                                            width: 48,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF3A8C8D),
                                                  Color(0xFF2D7A7B),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF2D7A7B).withOpacity(0.3),
                                                  blurRadius: _isButtonHovered ? 8 : 0,
                                                  spreadRadius: _isButtonHovered ? 2 : 0,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Método para navegar com animação para o scanner de QR Code
  void _navigateWithAnimation(BuildContext context) {
    // Animação de pressionar botão
    setState(() {
      _isButtonHovered = true;
    });
    
    // Delay para efeito visual antes de navegar
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _isButtonHovered = false;
      });
      
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const QRScannerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    });
  }
}