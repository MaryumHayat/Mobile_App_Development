import 'dart:ui';
import 'dart:developer' as dev; // For logging AI errors
import 'package:flutter/material.dart';
import 'checkout.dart';
import 'package:abaya_designer/services/ai_service.dart';

class DesignPage extends StatefulWidget {
  final VoidCallback onBack;
  final String? initialAbaya;
  final String? initialHijab;
  final Function(String?, String?) onSaveState; // Callback to save current design state (abaya, hijab)

  const DesignPage({
    super.key,
    required this.onBack,
    this.initialAbaya,  
    this.initialHijab,
    required this.onSaveState,
  });

  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  String? activeAbaya;
  String? activeHijab;
  String? lastSavedAbaya;
  String? lastSavedHijab;
  String selectedSize = 'M';

  final AIService _aiService = AIService(); // Instance of AI service for fetching recommendations
  String? aiReason;
  bool isAiLoading = false;

  final List<String> hijabItems = [
   'Sage Green Chiffon.png', 'Classic Black Silk.png', 'Deep Crimson Red.png', 'Dusty Rose.png', 
   'Cream with Teal.png', 'Slate Blue.png', 'Navy Blue.png', 'Soft Peach Chiffon.png', 'Ivory.png', 
   'Rose Gold Satin.png', 'Soft Mauve Satin.png', 'Light Grey.png'
  ];

  final List<String> abayaItems = [
    'Black and Orange.png', 'Olive and Cream.png', 'Dusty Rose and Cream.png','Cream and Burgundy.png', 'Maroon and Black.png',
    'Slate Blue and White.png', 'Black and White.png', 'Peach and Black.png', 'Light Brown.png', 'Black and Grey.png',
    'Emerald Green.png', 'Deep Crimson.png', 'Pristine White.png', 'Chocolate Brown.png', 'Powder Blue.png'
  ];

  @override
  void initState() {
    super.initState();
    activeAbaya = widget.initialAbaya;
    activeHijab = widget.initialHijab;
    lastSavedAbaya = widget.initialAbaya;
    lastSavedHijab = widget.initialHijab;
  }

  void _fetchAIAdvice(String abaya) async { // Fetch AI recommendation based on selected abaya
  if (!mounted) return; 

  setState(() {
    isAiLoading = true;
    aiReason = null;
  });

  try {
    final hijabMap = {
      for (var h in hijabItems) h: _getHijabColor(h) // Map hijab asset names to their color descriptions for AI input
    };

    final result = await _aiService.getRecommendation( // Call AI service with selected abaya color and available hijab options
      _getAbayaColor(abaya),
      hijabMap,
    );

    if (mounted) {
      setState(() {
        if (result != null && result['id'] != null) {
          activeHijab = result['id'];
          aiReason = result['reason'];
        } else {
          aiReason = "Stylist unavailable.";
        }
        isAiLoading = false;
      });
    }
  } catch (e) {
    dev.log("AI Error: $e"); // Log the error for debugging purposes
    if (mounted) {
      setState(() {
        isAiLoading = false;
        aiReason = "Connection issue.";
      });
    }
  }
}
       
  bool get hasUnsavedChanges =>
      activeAbaya != lastSavedAbaya || activeHijab != lastSavedHijab;

  void _saveCurrentState() {
    setState(() {
      lastSavedAbaya = activeAbaya;
      lastSavedHijab = activeHijab;
    });
    widget.onSaveState(activeAbaya, activeHijab);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Design saved!"),
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleBackNavigation() async { 
    if (!hasUnsavedChanges) {
      widget.onBack();
      return;
    }

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE5DED2),
        title: const Text("Unsaved Changes", style: TextStyle(fontFamily: 'Serif')),
        content: const Text("Would you like to save your design before leaving?"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                activeAbaya = null;
                activeHijab = null;
              });
              widget.onSaveState(null, null);
              Navigator.pop(context, 'discard');
            },
            child: const Text("Discard", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              _saveCurrentState();
              Navigator.pop(context, 'save');
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3E33)),
            child: const Text("Save & Exit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == 'discard' || result == 'save') {
      widget.onBack();
    }
  }

  String _getAbayaColor(String? asset) {
    switch (asset) {
      case 'Black and Orange.png': return "Black and Orange";
      case 'Olive and Cream.png': return "Olive and Cream";
      case 'Dusty Rose and Cream.png': return "Dusty Rose and Cream";
      case 'Cream and Burgundy.png': return "Cream and Burgundy";
      case 'Maroon and Black.png': return "Maroon and Black";
      case 'Slate Blue and White.png': return "Slate Blue and White";
      case 'Black and White.png': return "Black and White";
      case 'Peach and Black.png': return "Peach and Black";
      case 'Light Brown.png': return "Light Brown";
      case 'Black and Grey.png': return "Black and Grey";
      case 'Emerald Green.png': return "Emerald Green";
      case 'Deep Crimson.png': return "Deep Crimson";
      case 'Pristine White.png': return "Pristine White";
      case 'Chocolate Brown.png': return "Chocolate Brown";
      case 'Powder Blue.png': return "Powder Blue";
      default: return "Premium Abaya";
    }
  }

  String _getHijabColor(String? asset) {
    switch (asset) {
      case 'Sage Green Chiffon.png': return "Sage Green Chiffon";
      case 'Classic Black Silk.png': return "Classic Black Silk";
      case 'Deep Crimson Red.png': return "Deep Crimson Red";
      case 'Dusty Rose.png': return "Dusty Rose";
      case 'Cream with Teal.png': return "Cream with Teal";
      case 'Slate Blue.png': return "Slate Blue";
     
      case 'Navy Blue.png': return "Navy Blue";
      case 'Soft Peach Chiffon.png': return "Soft Peach Chiffon";
     
      case 'Ivory.png': return "Ivory";
      case 'Rose Gold Satin.png': return "Rose Gold Satin";
      case 'Soft Mauve Satin.png': return "Soft Mauve Satin";
      case 'Light Grey.png': return "Light Grey";
      default: return "Selected Shade";
    }
  }

  void _showDetailsSheet() {
    int abayaPrice = activeAbaya != null ? 3500 : 0;
    int hijabPrice = activeHijab != null ? 700 : 0;
    int totalPrice = abayaPrice + hijabPrice;

    showModalBottomSheet( // Show a bottom sheet with design details
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFE5DED2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder to manage state within the bottom sheet for size selection
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Design Details", style: TextStyle(fontFamily: 'Serif', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3E33))),
                  const SizedBox(height: 10),
                  if (activeAbaya == null && activeHijab == null)
                    const Text("You haven't designed your abaya yet.", style: TextStyle(fontSize: 15, color: Colors.black54, fontStyle: FontStyle.italic))
                  else ...[
                    if (activeAbaya != null) ...[
                      const Text("Abaya: Premium Collection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("Color: ${_getAbayaColor(activeAbaya)}", style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      Text("Price: Rs. $abayaPrice", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 10),
                    ],
                    if (activeHijab != null) ...[
                      const Text("Hijab: Premium Wrap", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("Color: ${_getHijabColor(activeHijab)}", style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      Text("Price: Rs. $hijabPrice", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ],
                  const SizedBox(height: 10),
                  const Text("Select Size", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Wrap( // Size selection chips
                    spacing: 12,
                    children: ['S', 'M', 'L', 'XL'].map((size) {
                      bool isSelected = selectedSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2D3E33),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        onSelected: (bool selected) {
                          setSheetState(() => selectedSize = size);
                          setState(() => selectedSize = size);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Payable", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text("Rs. $totalPrice", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3E33))),
                        ],
                      ),
                      const Text("(Inclusive of Tax)", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final mannequinHeight = screenHeight * 0.70; 

    return PopScope( // Use PopScope to intercept back navigation and handle unsaved changes
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async { // Intercept back navigation to handle unsaved changes
        if (didPop) return;
        await _handleBackNavigation(); 
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bgdesign.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // MANNEQUIN DISPLAY 
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.17), 
                    child: SizedBox(
                      height: mannequinHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/dummy1.png', height: mannequinHeight, fit: BoxFit.fitHeight),
                          if (activeAbaya != null)
                            Image.asset('assets/images/$activeAbaya', key: ValueKey(activeAbaya), height: mannequinHeight, fit: BoxFit.fitHeight),
                          if (activeHijab != null)
                            Image.asset('assets/images/$activeHijab', key: ValueKey(activeHijab), height: mannequinHeight, fit: BoxFit.fitHeight),
                        ],
                      ),
                    ),
                  ),
                ),

                // HEADER
                Positioned(
                  top: 10, left: 5, right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _handleBackNavigation(),
                        icon: const Icon(Icons.arrow_back_sharp, size: 32, color: Color(0xFF2D3E33)),
                      ),
                      const Text("My Studio", style: TextStyle(fontFamily: 'Serif', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3E33))),
                      IconButton(
                        onPressed: _saveCurrentState,
                        icon: Icon(
                          hasUnsavedChanges ? Icons.save_as : Icons.save,
                          size: 25,
                          color: hasUnsavedChanges ? const Color.fromARGB(255, 91, 103, 2) : const Color(0xFF2D3E33),
                        ),
                      ),
                    ],
                  ),
                ),

                if (isAiLoading || aiReason != null) // AI RECOMMENDATION OVERLAY
                Positioned(
                  top: 75,
                  left: 20, 
                  child: Center(
                    child: ConstrainedBox( 
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.60),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: -15, left: 0, right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.transparent
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Content Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F2EC).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2D3E33).withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(3, 3),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      blurRadius: 15,
                                      offset: const Offset(-3, -3),
                                    ),
                                  ],
                                ),
                                child: isAiLoading  // Show loading indicator while waiting for AI response, otherwise show the AI's style note or reason for recommendation
                                  ? const Column(
                                      children: [
                                        SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2D3E33))),
                                        SizedBox(height: 8),
                                        Text("Stylist is thinking...", style: TextStyle(fontSize: 10, color: Color(0xFF2D3E33))),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.auto_awesome, size: 12, color: Color(0xFF2D3E33)),
                                            SizedBox(width: 6),
                                            Text("STYLE NOTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 1.1, color: Color(0xFF2D3E33))),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          aiReason ?? "", 
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black, height: 1.2),
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SELECTION RAILS 
                Positioned(
                  right: screenWidth * 0.04, 
                  top: screenHeight * 0.12, 
                  bottom: screenHeight * 0.12,
                  child: SizedBox(
                    width: 65,
                    child: Column(
                      children: [
                        _buildRailLabel("Abaya"),
                        const Icon(Icons.arrow_drop_up, size: 18),
                        Expanded(child: _buildList(abayaItems, true)),
                        const Icon(Icons.arrow_drop_down, size: 18),
                        SizedBox(height: screenHeight * 0.02),
                        _buildRailLabel("Hijab"),
                        const Icon(Icons.arrow_drop_up, size: 18),
                        Expanded(child: _buildList(hijabItems, false)),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),

                // BOTTOM BUTTONS
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: _showDetailsSheet,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2D3E33), width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 15),
                          ),
                          child: const Text("Details", style: TextStyle(color: Color(0xFF2D3E33), fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton(
                          onPressed: () {
                            if (activeAbaya == null && activeHijab == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please design first!")));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(
                                selectedAbaya: activeAbaya,
                                selectedHijab: activeHijab,
                                selectedSize: selectedSize,
                                abayaColor: _getAbayaColor(activeAbaya),
                                hijabColor: _getHijabColor(activeHijab),
                              )));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3E33),
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text("Order Now", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRailLabel(String text) => Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D3E33)));

  Widget _buildList(List<String> items, bool isAbaya) {
    return ListView.builder( // Build a list of design options
      padding: EdgeInsets.zero,
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        bool isNoneOption = index == 0;
        String? itemPath = isNoneOption ? null : items[index - 1];
        bool isSelected = isAbaya ? (activeAbaya == itemPath) : (activeHijab == itemPath);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isAbaya) { 
                activeAbaya = itemPath; 
                // Matching hijab is applied automatically in _fetchAIAdvice
                if (itemPath != null) _fetchAIAdvice(itemPath); 
              } else { 
                activeHijab = itemPath; 
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF354F36).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2D3E33) : Colors.white.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: isNoneOption
                      ? const Icon(Icons.close, color: Color(0xFF2D3E33), size: 20)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/$itemPath',
                            alignment: isAbaya ? Alignment.center : Alignment.topCenter,
                            fit: isAbaya ? BoxFit.fitHeight : BoxFit.cover,
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
}