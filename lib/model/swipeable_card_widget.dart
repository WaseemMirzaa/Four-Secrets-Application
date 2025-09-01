import 'dart:async';
import 'package:flutter/material.dart';
import 'package:four_secrets_wedding_app/extension.dart';

// ignore: must_be_immutable
class SwipeableCardWidget extends StatefulWidget {
  List<String> images;
  double height;
  String imageFit; // New: Control how images are fitted
  bool showIndicators; // New: Control indicator visibility
  bool showSwipeHints; // New: Control swipe hint visibility
  bool useImageDimensions; // New: Use actual image dimensions for sizing
  double widthRatio; // New: Width ratio relative to screen width

  SwipeableCardWidget({
    super.key,
    required this.images,
    required this.height,
    this.imageFit = "cover", // Default to cover to fill card shape
    this.showIndicators = true,
    this.showSwipeHints = true,
    this.useImageDimensions = false, // Default to fixed height
    this.widthRatio = 0.67, // Default to 67% of screen width
  });

  @override
  _SwipeableCardWidgetState createState() => _SwipeableCardWidgetState();
}

class _SwipeableCardWidgetState extends State<SwipeableCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  bool _isAnimating = false;
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  Map<String, Size> _imageDimensions = {}; // Store dimensions for each image

  @override
  void initState() {
    super.initState();

    // Load image dimensions if enabled
    if (widget.useImageDimensions && widget.images.isNotEmpty) {
      _loadAllImageDimensions();
    }

    _animationController = AnimationController(
      duration: Duration(
          milliseconds: 200), // Faster animation for better responsiveness
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(2.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;
    _animationController.stop(); // Fixed: Stop any ongoing animation
    _animationController.reset();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;

    setState(() {
      _dragOffset += details.delta;
      // Improved: More sensitive rotation calculation
      _dragRotation = (_dragOffset.dx / 200 * 0.15).clamp(-0.4, 0.4);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold =
        screenWidth * 0.15; // Reduced from 0.3 to 0.15 for easier swiping
    final velocity = details.velocity.pixelsPerSecond.dx.abs();
    final velocityThreshold = 300; // Minimum velocity for quick swipes

    // Check for swipe based on distance OR velocity
    bool shouldSwipe =
        _dragOffset.dx.abs() > threshold || velocity > velocityThreshold;

    if (shouldSwipe) {
      // Swipe detected - determine direction
      bool swipeRight =
          _dragOffset.dx > 0 || details.velocity.pixelsPerSecond.dx > 0;
      _swipeCard(swipeRight);
    } else {
      // Return to center with animation
      _returnToCenter();
    }
  }

  void _returnToCenter() {
    _isAnimating = true;

    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // Changed: Smoother return animation
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragRotation,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // Changed: Smoother return animation
    ));

    _animationController.forward().then((_) {
      if (mounted) {
        // Fixed: Check if widget is still mounted
        setState(() {
          _dragOffset = Offset.zero;
          _dragRotation = 0.0;
          _isAnimating = false;
        });
        _animationController.reset();
      }
    });
  }

  void _swipeCard(bool swipeRight) {
    _isAnimating = true;

    _slideAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(swipeRight ? 2.0 : -2.0, _dragOffset.dy),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragRotation,
      end: swipeRight ? 0.3 : -0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          // Move the first image to the end
          final firstImage = widget.images.removeAt(0);
          widget.images.add(firstImage);

          _dragOffset = Offset.zero;
          _dragRotation = 0.0;
          _isAnimating = false;
        });
        _animationController.reset();
      }
    });
  }

  Widget buildImage(
      BuildContext context, String image, int index, String mode) {
    // Get the calculated size for this specific image
    final Size imageSize = _calculateCardSize(image, context);

    return Container(
      width: imageSize.width,
      height: imageSize.height,
      child: Image.asset(
        image,
        fit: BoxFit
            .scaleDown, // Scale down to fit within container while maintaining aspect ratio
        width: imageSize.width,
        height: imageSize.height,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[600],
              size: 50,
            ),
          );
        },
      ),
    );
  }

  // Load dimensions for all images
  Future<void> _loadAllImageDimensions() async {
    print('🔄 Starting to load all image dimensions...');
    if (widget.images.isEmpty) {
      print('❌ No images provided');
      return;
    }

    try {
      for (String imagePath in widget.images) {
        print('📸 Loading image: $imagePath');
        final ImageProvider imageProvider = AssetImage(imagePath);

        final ImageStream stream =
            imageProvider.resolve(ImageConfiguration.empty);
        final Completer<ImageInfo> completer = Completer<ImageInfo>();

        void listener(ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete(info);
          }
        }

        stream.addListener(ImageStreamListener(listener));

        final ImageInfo imageInfo = await completer.future;
        final double imageWidth = imageInfo.image.width.toDouble();
        final double imageHeight = imageInfo.image.height.toDouble();

        // Store dimensions for this specific image
        _imageDimensions[imagePath] = Size(imageWidth, imageHeight);
        print('🖼️ Image $imagePath dimensions: ${imageWidth}x${imageHeight}');

        stream.removeListener(ImageStreamListener(listener));
      }

      if (mounted) {
        setState(() {
          print(
              '✅ All image dimensions loaded: ${_imageDimensions.length} images');
        });
      }
    } catch (e) {
      print('❌ Error loading image dimensions: $e');
    }
  }

  // Calculate card size for a specific image
  Size _calculateCardSize(String imagePath, BuildContext context) {
    if (!widget.useImageDimensions ||
        !_imageDimensions.containsKey(imagePath)) {
      // Use default sizing
      final double width = context.screenWidth * widget.widthRatio;
      final double height = widget.height;
      return Size(width, height);
    }

    final Size imageSize = _imageDimensions[imagePath]!;
    final double aspectRatio = imageSize.width / imageSize.height;
    final bool isLandscape = imageSize.width > imageSize.height;

    double cardWidth;
    double cardHeight;

    // Calculate maximum constraints
    final double maxHeight = widget.height - 30.0; // 30 points buffer
    final double maxWidth =
        MediaQuery.of(context).size.width * widget.widthRatio;
    final double minHeight = widget.height * 0.5;

    if (isLandscape) {
      // For landscape images (width > height), start with width constraint
      cardWidth = maxWidth;
      cardHeight = cardWidth / aspectRatio;

      // If calculated height exceeds max height, adjust both dimensions
      if (cardHeight > maxHeight) {
        cardHeight = maxHeight;
        cardWidth = cardHeight * aspectRatio;
      }

      // For landscape images, ensure minimum height is reasonable (at least 200px)
      final double minLandscapeHeight = 200.0;
      if (cardHeight < minLandscapeHeight) {
        cardHeight = minLandscapeHeight;
        cardWidth = cardHeight * aspectRatio;
        // If width becomes too large, cap it and adjust height back
        if (cardWidth > maxWidth) {
          cardWidth = maxWidth;
          cardHeight = cardWidth / aspectRatio;
        }
      }

      print(
          '🖼️ Landscape image: ${imageSize.width.toInt()}x${imageSize.height.toInt()}');
    } else {
      // For portrait images (height > width), start with height constraint
      cardHeight = maxHeight;
      cardWidth = cardHeight * aspectRatio;

      // If calculated width exceeds max width, adjust both dimensions
      if (cardWidth > maxWidth) {
        cardWidth = maxWidth;
        cardHeight = cardWidth / aspectRatio;
      }

      print(
          '🖼️ Portrait image: ${imageSize.width.toInt()}x${imageSize.height.toInt()}');
    }

    // Ensure minimum height
    if (cardHeight < minHeight) {
      cardHeight = minHeight;
      cardWidth = cardHeight * aspectRatio;
    }

    print(
        '� Card size for $imagePath: ${cardWidth.toInt()}x${cardHeight.toInt()}');
    return Size(cardWidth, cardHeight);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions for the current top image
    final String currentImagePath =
        widget.images.isNotEmpty ? widget.images[0] : '';
    final Size cardSize = _calculateCardSize(currentImagePath, context);

    final double cardWidth = cardSize.width;
    final double cardHeight = cardSize.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card container
        SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background cards (tilted)
              for (int i = widget.images.length - 1; i >= 1; i--)
                _buildBackgroundCard(i),

              // Top card (interactive)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Calculate swipe progress for visual feedback
                  final screenWidth = MediaQuery.of(context).size.width;
                  final swipeProgress =
                      (_dragOffset.dx.abs() / (screenWidth * 0.15))
                          .clamp(0.0, 1.0);
                  final scale = 1.0 -
                      (swipeProgress * 0.05); // Slight scale down when swiping

                  return Transform.scale(
                    scale: scale,
                    child: Transform.translate(
                      offset: _isAnimating
                          ? Offset(
                              _slideAnimation.value.dx *
                                  MediaQuery.of(context).size.width,
                              _slideAnimation.value.dy,
                            )
                          : _dragOffset,
                      child: Transform.rotate(
                        angle: _isAnimating
                            ? _rotationAnimation.value
                            : _dragRotation,
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: _buildCard(widget.images[0], 0, swipeProgress),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 25 padding between card and indicators
        // if (widget.showIndicators && widget.images.length > 1)
        //   SizedBox(height: 25),

        // // Indicator dots outside the card
        // if (widget.showIndicators && widget.images.length > 1)
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: List.generate(
        //       widget.images.length,
        //       (i) => Container(
        //         margin: EdgeInsets.symmetric(horizontal: 3),
        //         width: 8,
        //         height: 8,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: i == 0 ? Colors.grey[800] : Colors.grey[400],
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildBackgroundCard(int index) {
    final image = widget.images[index];
    final scale = 1.0 - (index * 0.05);
    final yOffset = index * 8.30;

    // Fixed tilt pattern: first background card tilts left, second tilts right
    double tiltAngle;
    if (index == 1) {
      tiltAngle = -0.13; // First background card tilts left
    } else if (index == 2) {
      tiltAngle = -0.28; // Second background card tilts right
    } else {
      // For additional cards, alternate the pattern
      tiltAngle = (index % 2 == 1) ? -0.05 : 0.05;
    }

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: tiltAngle,
          child: _buildCard(image, index, 0.0),
        ),
      ),
    );
  }

  Widget _buildCard(String imagePath, int index, [double swipeProgress = 0.0]) {
    // Calculate dimensions for this specific card
    final Size cardSize = _calculateCardSize(imagePath, context);

    // Visual feedback based on swipe direction
    Color overlayColor = Colors.transparent;
    if (swipeProgress > 0) {
      // Determine swipe direction
      // if (_dragOffset.dx > 0) {
      //   // Swiping right - green success color
      //   overlayColor = Colors.green.withValues(alpha: 0.2 * swipeProgress);
      // } else if (_dragOffset.dx < 0) {
      //   // Swiping left - blue info color
      //   overlayColor = Colors.blue.withValues(alpha: 0.2 * swipeProgress);
      // }
    }

    return Container(
      width: cardSize.width,
      height: cardSize.height,
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1 + (0.1 * swipeProgress)),
            spreadRadius: 2 + swipeProgress,
            blurRadius: 10 + (5 * swipeProgress),
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: buildImage(context, imagePath, index, widget.imageFit),
          ),

          // Swipe hint overlay
          if (widget.showSwipeHints && widget.images.length > 1)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),

          // Swipe direction overlay
          if (swipeProgress > 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: overlayColor,
                ),
              ),
            ),

          // Swipe instruction hint (only shown for the top card when not swiping)
          // if (widget.showSwipeHints &&
          //     widget.images.length > 1 &&
          //     index == 0 &&
          //     swipeProgress < 0.1)
          //   Positioned(
          //     bottom: widget.showIndicators ? 30 : 10,
          //     left: 0,
          //     right: 0,
          //     child: Center(
          //       child: Container(
          //         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //         decoration: BoxDecoration(
          //           color: Colors.black.withValues(alpha: 0.5),
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //         child: Text(
          //           "← Swipe →",
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 12,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
