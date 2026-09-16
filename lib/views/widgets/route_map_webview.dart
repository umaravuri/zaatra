import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class RouteMapWebView extends StatefulWidget {
  final String? pickup;
  final String? destination;
  final String? rideId;
  final double height;
  final double borderRadius;
  final bool showNavigationOverlay;
  final bool interactive;
  final VoidCallback? onTap;

  const RouteMapWebView({
    super.key,
    this.pickup,
    this.destination,
    this.rideId,
    this.height = 200,
    this.borderRadius = 16,
    this.showNavigationOverlay = false,
    this.interactive = true,
    this.onTap,
  });

  @override
  State<RouteMapWebView> createState() => _RouteMapWebViewState();
}

class _RouteMapWebViewState extends State<RouteMapWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = _buildMapUrl();
    _initWebView();
  }

  String _buildMapUrl() {
    if (widget.rideId != null && widget.rideId!.isNotEmpty) {
      return '${ApiService.baseUrl}/rides/${widget.rideId}/map-view';
    }

    final p = widget.pickup?.trim() ?? 'Vijayawada';
    final d = widget.destination?.trim() ?? 'Hyderabad';

    return '${ApiService.baseUrl}/rides/map-view?pickup=${Uri.encodeComponent(p)}&destination=${Uri.encodeComponent(d)}';
  }

  void _initWebView() {
    if (kIsWeb) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFE8DEF8))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              }
            },
          ),
        );

      if (_currentUrl.isNotEmpty) {
        controller.loadRequest(
          Uri.parse(_currentUrl),
          headers: const {
            'Bypass-Tunnel-Reminder': 'true',
          },
        );
      }

      _controller = controller;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant RouteMapWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newUrl = _buildMapUrl();
    if (newUrl != _currentUrl) {
      _currentUrl = newUrl;
      if (_controller != null) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
        _controller!.loadRequest(
          Uri.parse(_currentUrl),
          headers: const {
            'Bypass-Tunnel-Reminder': 'true',
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE8DEF8),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            // Map WebView or Fallback
            if (_controller != null && !_hasError)
              Positioned.fill(
                child: WebViewWidget(
                  controller: _controller!,
                  gestureRecognizers: widget.interactive
                      ? {
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        }
                      : {},
                ),
              )
            else if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined, color: AppColors.primary, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.pickup ?? "Origin"}  ➔  ${widget.destination ?? "Destination"}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          _initWebView();
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reload Map'),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            // Loading Overlay
            if (_isLoading && !_hasError)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF3EDF7).withAlpha(180),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Loading route map...',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Navigation Tap Overlay if requested
            if (widget.showNavigationOverlay)
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(235),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.near_me_rounded, size: 14, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              'Tap map to open Google Maps navigation',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Invisible Tap detector if onTap is provided and not interactive
            if (widget.onTap != null && !widget.interactive)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
