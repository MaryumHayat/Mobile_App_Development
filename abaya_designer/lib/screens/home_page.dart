import 'package:flutter/material.dart';
import 'beforehome.dart';
import 'package:abaya_designer/cart_model.dart'; 

List<String> savedDesigns = [];

class HomePage extends StatefulWidget {
  final VoidCallback onCartUpdated;
  const HomePage({super.key, required this.onCartUpdated});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String price = "Rs. 4,500";
  late PageController _pageController;
  double _currentPage = 0.0;
  String? _enlargedImage;

  @override
  void initState() {
    super.initState();
    // CHANGE: Increased viewportFraction from 0.65 to 0.82 
    // This makes the card wider (less "thin") while still showing side cards
    _pageController = PageController(viewportFraction: 0.8); 
    _pageController.addListener(() {
      if (mounted) setState(() => _currentPage = _pageController.page ?? 0.0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getAbayaDescription(String asset) {
    switch (asset) {
      case 'h1.jpg': return "Cream floral cotton-blend top with a breathable maroon linen-style skirt.";
      case 'h2.jpg': return "Black jersey knit top over a fluid, abstract-print white crepe skirt.";
      case 'h3.jpg': return "Dual-tone Nida crepe in slate blue and floral-printed off-white.";
      case 'h4.jpg': return "Soft lavender textured linen featuring white geometric vertical embroidery.";
      case 'h5.jpg': return "Ribbed burgundy knit top paired with a floral black crepe skirt.";
      case 'h6.jpg': return "Peach ribbed sweater top over a black floral-print satin-crepe skirt.";
      case 'h7.jpg': return "Dual-tone Nida crepe in slate blue and floral-printed off-white.";
      case 'h8.jpg': return "Mocha Lexus crepe featuring a botanical-patterned tan contrast panel.";
      case 'h9.jpg': return "Matte charcoal crepe accented with a textured smoky-grey artistic panel.";
      case 'h10.jpg': return "Midnight black Nida crepe with a vibrant burnt orange silk-crepe contrast.";
      case 'h11.jpg': return "Dusty rose Nida crepe with a floral-printed cream contrast panel.";
      case 'h12.jpg': return "Olive green textured linen with a geometric embroidered cream accent.";
      default: return "Timeless Elegant Design";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> collectionImages = List.generate(12, (i) => 'h${i + 1}.jpg'); 

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E6),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/homebg.png', fit: BoxFit.cover)),
          SafeArea( 
            child: LayoutBuilder( 
              builder: (context, constraints) {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.08, vertical: 25),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.widgets, color: Colors.white, size: constraints.maxWidth * 0.08),
                            onPressed: () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const BeforeHome())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text("OUR COLLECTION",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: constraints.maxWidth * 0.06, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white, 
                            letterSpacing: 4.0)),
                    Expanded(
                      child: PageView.builder( 
                        controller: _pageController,
                        itemCount: collectionImages.length,
                        itemBuilder: (context, index) {
                          double scaleValue = (1 - ((index - _currentPage).abs() * 0.2)).clamp(0.8, 1.0); 
                          return Transform.scale(
                            scale: scaleValue,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: constraints.maxHeight * 0.02),
                              child: GridItemCard(
                                img: collectionImages[index],
                                description: _getAbayaDescription(collectionImages[index]),
                                price: price,
                                onTap: () => setState(() => _enlargedImage = collectionImages[index]),
                                onCartUpdated: widget.onCartUpdated,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            ),
          ),

          if (_enlargedImage != null) 
            GestureDetector(
              onTap: () => setState(() => _enlargedImage = null),
              child: Container(
                color: Colors.black.withValues(alpha: .9),
                child: Stack(
                  children: [
                    Center(
                      child: Hero(
                        tag: _enlargedImage!,
                        child: Image.asset('assets/images/$_enlargedImage', fit: BoxFit.contain),
                      ),
                    ),
                    Positioned(
                      top: 40, right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 35),
                        onPressed: () => setState(() => _enlargedImage = null),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GridItemCard extends StatefulWidget {
  final String img;
  final String description;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onCartUpdated;

  const GridItemCard({
    super.key, required this.img, required this.description, 
    required this.price, required this.onTap, required this.onCartUpdated,
  });

  @override
  State<GridItemCard> createState() => _GridItemCardState();
}

class _GridItemCardState extends State<GridItemCard> with TickerProviderStateMixin {
  bool isLiked = false;
  bool showHeartOverlay = false;
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    isLiked = savedDesigns.contains(widget.img);
    _heartController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void handleDoubleTap() {
    setState(() {
      isLiked = true;
      showHeartOverlay = true;
      if (!savedDesigns.contains(widget.img)) savedDesigns.add(widget.img);
    });
    _heartController.forward(from: 0).then((_) { 
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() => showHeartOverlay = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                // CHANGE: Reduced flex from 3 to 2.5 to give the text area more room
                flex: 25, 
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: widget.onTap,
                      onDoubleTap: handleDoubleTap,
                      child: Hero(
                        tag: widget.img,
                        child: Image.asset('assets/images/${widget.img}', 
                        fit: BoxFit.cover,
                        width: double.infinity, height: double.infinity),
                      ),
                    ),
                    
                    if (showHeartOverlay)
                      Center(
                        child: ScaleTransition( 
                          scale: TweenSequence<double>([
                            TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.elasticOut)), weight: 50),
                            TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
                          ]).animate(_heartController),
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) { 
                              return const RadialGradient(
                                center: Alignment.bottomLeft,
                                radius: 1.2,
                                colors: [Color(0xFFFDCB5C), Color(0xFFFD5949), Color(0xFFD6249F), Color(0xFF285AEB)],
                                stops: [0.2, 0.5, 0.8, 1.0],
                              ).createShader(bounds);
                            },
                            child: const Icon(Icons.favorite, size: 100, color: Colors.white),
                          ),
                        ),
                      ),
                    
                    Positioned(
                      top: 10, right: 10,
                      child: IconButton(
                        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white, size: constraints.maxWidth * 0.1),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                            isLiked ? savedDesigns.add(widget.img) : savedDesigns.remove(widget.img); 
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                // CHANGE: Increased flex ratio for the info section
                flex: 10, 
                child: Container(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.description, 
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          // CHANGE: Increased font size multiplier from 0.045 to 0.052
                          fontSize: constraints.maxWidth * 0.050, 
                          height: 1.2, 
                          color: Colors.black87,
                          fontWeight: FontWeight.w500)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.price, style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            // CHANGE: Slightly increased price font size
                            fontSize: constraints.maxWidth * 0.058, 
                            color: Colors.brown)),
                          ElevatedButton.icon(
                            onPressed: () {
                              globalCart.add(CartItem(image: widget.img, description: widget.description, basePrice: 4500));
                              widget.onCartUpdated();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D2D2D), 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text("Add"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}