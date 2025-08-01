import 'package:flutter/material.dart';
import 'dart:math' as math;

class SwipeAction {
  const SwipeAction({
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.red,
    this.iconColor = Colors.white,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final String? label;
}

class SwipeableWidget extends StatefulWidget {
  const SwipeableWidget({
    super.key,
    required this.child,
    required this.actions,
    this.actionExtent = 80.0,
    this.threshold = 0.3,
    this.animationDuration = const Duration(milliseconds: 350),
    this.borderRadius = 12.0,
    this.enableHaptics = true,
  }) : assert(actions.length > 0 && actions.length <= 4);

  final Widget child;
  final List<SwipeAction> actions;
  final double actionExtent;
  final double threshold;
  final Duration animationDuration;
  final double borderRadius;
  final bool enableHaptics;

  @override
  State<SwipeableWidget> createState() => _SwipeableWidgetState();
}

class _SwipeableWidgetState extends State<SwipeableWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _iconController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  
  double _dragExtent = 0.0;
  bool _isOpen = false;
  bool _hasTriggeredHaptic = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutQuart,
    ));
    
    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));
    
    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  double get _totalActionWidth => widget.actions.length * widget.actionExtent;

  void _triggerHaptic() {
    if (widget.enableHaptics && !_hasTriggeredHaptic) {
      // HapticFeedback.lightImpact();
      _hasTriggeredHaptic = true;
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _slideController.stop();
    _scaleController.forward();
    _hasTriggeredHaptic = false;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta!;
    final oldDragExtent = _dragExtent;
    
    _dragExtent = (_dragExtent - delta).clamp(0.0, _totalActionWidth);
    
    // Trigger haptic feedback when crossing threshold
    final threshold = _totalActionWidth * widget.threshold;
    if (_dragExtent > threshold && oldDragExtent <= threshold) {
      _triggerHaptic();
      _iconController.forward().then((_) => _iconController.reverse());
    }

    if (oldDragExtent != _dragExtent) {
      setState(() {});
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _scaleController.reverse();
    
    final velocity = details.primaryVelocity ?? 0.0;
    final threshold = _totalActionWidth * widget.threshold;
    
    bool shouldOpen = false;
    
    if (velocity.abs() > 400) {
      shouldOpen = velocity < 0;
    } else {
      shouldOpen = _dragExtent > threshold;
    }
    
    _animateToPosition(shouldOpen ? _totalActionWidth : 0.0);
  }

  void _animateToPosition(double target) {
    final startPosition = _dragExtent;
    
    _slideController.reset();
    
    final animation = Tween<double>(
      begin: startPosition,
      end: target,
    ).animate(_slideAnimation);
    
    animation.addListener(() {
      setState(() {
        _dragExtent = animation.value;
      });
    });
    
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isOpen = target > 0;
      }
    });
    
    _slideController.forward();
  }

  void _close() {
    _animateToPosition(0.0);
  }

  void _handleActionTap(SwipeAction action) {
    // Animate action button press
    _scaleController.forward().then((_) {
      _scaleController.reverse();
      _close();
      action.onTap();
    });
  }

  Widget _buildActionButton(SwipeAction action, int index) {
    final progress = (_dragExtent / _totalActionWidth).clamp(0.0, 1.0);
    final staggerDelay = index * 0.1;
    final animationProgress = (progress - staggerDelay).clamp(0.0, 1.0);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_iconScaleAnimation, _iconRotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationProgress),
          child: Transform.rotate(
            angle: _iconRotationAnimation.value * (index.isEven ? 1 : -1),
            child: Container(
              width: widget.actionExtent,
              margin: EdgeInsets.only(
                top: 4 * (1 - animationProgress),
                bottom: 4 * (1 - animationProgress),
                right: index == widget.actions.length - 1 ? 0 : 2,
              ),
              decoration: BoxDecoration(
                color: action.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: index == widget.actions.length - 1 
                      ? Radius.circular(widget.borderRadius) 
                      : Radius.zero,
                  bottomLeft: index == widget.actions.length - 1 
                      ? Radius.circular(widget.borderRadius) 
                      : Radius.zero,
                  topRight: index == 0 
                      ? Radius.circular(widget.borderRadius) 
                      : Radius.zero,
                  bottomRight: index == 0 
                      ? Radius.circular(widget.borderRadius) 
                      : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.backgroundColor.withOpacity(0.3),
                    blurRadius: 8 * animationProgress,
                    offset: Offset(-2, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  onTap: () => _handleActionTap(action),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: _iconScaleAnimation.value,
                        child: Icon(
                          action.icon,
                          color: action.iconColor,
                          size: 22,
                        ),
                      ),
                      if (action.label != null) ...[
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          opacity: animationProgress > 0.7 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          child: Text(
                            action.label!,
                            style: TextStyle(
                              color: action.iconColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragExtent / _totalActionWidth).clamp(0.0, 1.0);
    
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05 + (0.1 * progress)),
                    blurRadius: 8 + (12 * progress),
                    offset: Offset(0, 2 + (4 * progress)),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background actions with staggered animation
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.actions
                          .asMap()
                          .entries
                          .map((entry) => _buildActionButton(entry.value, entry.key))
                          .toList(),
                    ),
                  ),
                  
                  // Main content with enhanced animations
                  Transform.translate(
                    offset: Offset(-_dragExtent, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: _dragExtent > 0 ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(-2, 0),
                          ),
                        ] : null,
                      ),
                      child: widget.child,
                    ),
                  ),
                  
                  // Subtle indicator line
                  if (_dragExtent > 0)
                    Positioned(
                      right: _totalActionWidth - _dragExtent,
                      top: 0,
                      bottom: 0,
                      width: 2,
                      child: AnimatedOpacity(
                        opacity: progress > 0.1 ? 0.6 : 0.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }