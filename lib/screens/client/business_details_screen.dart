// Fichier screens/client/business_details_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/business_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../l10n/translations.dart';
import '../../services/error_handler.dart';
// Imports à ajouter
import '../../widgets/client/product_card.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';

class BusinessDetailsScreen extends StatefulWidget {
  final BusinessModel business;

  const BusinessDetailsScreen({super.key, required this.business});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products =
          await _productService.getBusinessProducts(widget.business.id);

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          e,
          fallbackMessage:
              AppTranslations.text(context, 'error_loading_products'),
          onRetry: _loadProducts,
        );
      }
    }
  }

  // Fonction de partage
  void _shareBusiness(BuildContext context) {
    final String message = """
${widget.business.name}
${widget.business.businessType == 'fixe' ? AppTranslations.text(context, 'fixed_business') : AppTranslations.text(context, 'mobile_business')}
${widget.business.isOpenNow() ? AppTranslations.text(context, 'open') : AppTranslations.text(context, 'closed')} - ${AppTranslations.text(context, 'opening_hours')}: ${widget.business.openingTime} - ${widget.business.closingTime}
${widget.business.address.isNotEmpty ? '${AppTranslations.text(context, 'address')}: ${widget.business.address}' : ''}
${widget.business.description.isNotEmpty ? '\n${widget.business.description}' : ''}

${AppTranslations.text(context, 'discover_app')}
""";

    Share.share(message,
        subject: AppTranslations.textWithParams(
            context, 'discover_business', [widget.business.name]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.business.name,
        showBackButton: true,
        actions: [
          // Bouton de favoris
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppTranslations.textWithParams(context,
                        'added_to_favorites', [widget.business.name]))),
              );
            },
          ),
          // Bouton de partage
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareBusiness(context),
            tooltip: AppTranslations.text(context, 'share'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de commerce et statut (ouvert/fermé)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    widget.business.businessType == 'fixe'
                        ? AppTranslations.text(context, 'fixed_business')
                        : AppTranslations.text(context, 'mobile_business'),
                  ),
                  backgroundColor: widget.business.businessType == 'fixe'
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                ),
                Chip(
                  label: Text(
                    widget.business.isOpenNow()
                        ? AppTranslations.text(context, 'open')
                        : AppTranslations.text(context, 'closed'),
                  ),
                  backgroundColor: widget.business.isOpenNow()
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              AppTranslations.text(context, 'description'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.business.description),
            const SizedBox(height: 16),

            // Heures d'ouverture
            Text(
              AppTranslations.text(context, 'opening_hours'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
                '${AppTranslations.text(context, 'from')} ${widget.business.openingTime} ${AppTranslations.text(context, 'to')} ${widget.business.closingTime}'),
            const SizedBox(height: 16),

            // Adresse
            if (widget.business.address.isNotEmpty) ...[
              Text(
                AppTranslations.text(context, 'address'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.business.address),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.map),
                label: Text(AppTranslations.text(context, 'open_in_maps')),
                onPressed: () => _openMap(context, widget.business.latitude,
                    widget.business.longitude),
              ),
              const SizedBox(height: 16),
            ],

            // Téléphone
            if (widget.business.phone.isNotEmpty) ...[
              Text(
                AppTranslations.text(context, 'contact'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(widget.business.phone),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.phone),
                    label: Text(AppTranslations.text(context, 'call')),
                    onPressed: () => _callPhone(context, widget.business.phone),
                  ),
                ],
              ),
            ],

            // Boutons d'action
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.directions,
                  label: AppTranslations.text(context, 'directions'),
                  color: Colors.blue,
                  onTap: () => _openMap(context, widget.business.latitude,
                      widget.business.longitude),
                ),
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: AppTranslations.text(context, 'favorites'),
                  color: Colors.red,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppTranslations.textWithParams(context,
                              'added_to_favorites', [widget.business.name]))),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.share,
                  label: AppTranslations.text(context, 'share'),
                  color: Colors.green,
                  onTap: () => _shareBusiness(context),
                ),
              ],
            ),

            // Products section
            const SizedBox(height: 24),
            Text(
              AppTranslations.text(context, 'products'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? Center(
                        child: Text(
                          AppTranslations.text(
                              context, 'no_products_available'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: _products[index],
                            business: widget.business,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/client/product-detail',
                                arguments: _products[index],
                              );
                            },
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(
      BuildContext context, double latitude, double longitude) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        fallbackMessage: AppTranslations.text(context, 'error_opening_maps'),
        onRetry: () => _openMap(context, latitude, longitude),
      );
    }
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
    final Uri url = Uri.parse('tel:$phone');

    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        fallbackMessage: AppTranslations.text(context, 'error_making_call'),
        onRetry: () => _callPhone(context, phone),
      );
    }
  }
}

// Widget pour les boutons d'action
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
