import 'package:flutter/material.dart';
import 'package:teste/src/config/app_data.dart' as appData;
import 'package:teste/src/config/custom_colors.dart';
import 'package:teste/src/models/cart_item_model.dart';
import 'package:teste/src/models/order_model.dart';
import 'package:teste/src/pages/cart/components/cart_tile.dart';
import 'package:teste/src/pages/common_widgets/payment_dialog.dart';
import 'package:teste/src/services/utils_services.dart';


class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final UtilsServices utilsServices = UtilsServices();
  List<CartItemModel> cartItems = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      cartItems = appData.cartItems;
    });
  }

  void removeItemFromCart(CartItemModel cartItem) {
    setState(() {
      cartItems.remove(cartItem);
      utilsServices.showToast(
          message: '${cartItem.item.itemName} removido(a) do carrinho');
    });
  }

  double cartTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item.totalPrice();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_shopping_cart,
                        size: 40,
                        color: CustomColors.customSwatchColor,
                      ),
                      const Text('Não há itens no carrinho'),
                    ],
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (_, index) {
                      return CartTile(
                        cartItem: cartItems[index],
                        remove: removeItemFromCart,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 3, spreadRadius: 2),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Total geral', style: TextStyle(fontSize: 12)),
                Text(
                  utilsServices.priceToCurrency(cartTotalPrice(), 2),
                  style: TextStyle(
                    fontSize: 23,
                    color: CustomColors.customSwatchColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.customSwatchColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    onPressed: cartItems.isEmpty ? null : () async {
                      bool? result = await showOrderConfirmation();
                      
                      if (result ?? false) {
                        
                        final order = OrderModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          createdDateTime: DateTime.now(),
                          overdueDateTime: DateTime.now().add(const Duration(minutes: 15)),
                          items: List.from(cartItems),
                          status: 'pending_payment',
                          copyAndPaste: 'q1w2e3r4t5y6', 
                          total: cartTotalPrice(),
                        );

                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => PaymentDialog(order: order),
                        );
                      } else {
                        if (!mounted) return;
                        utilsServices.showToast(
                          message: 'Pedido não confirmado',
                          isError: true,
                        );
                      }
                    },
                    child: const Text('Concluir pedido', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> showOrderConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente concluir o pedido?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Não'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }
}