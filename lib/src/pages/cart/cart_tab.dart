import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste/src/config/custom_colors.dart';
import 'package:teste/src/models/cart_item_model.dart';
import 'package:teste/src/models/item_model.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void removeItemFromCart(String productId) {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete()
        .then((_) {
      utilsServices.showToast(message: 'Item removido do carrinho');
    }).catchError((error) {
      utilsServices.showToast(message: 'Erro ao remover item', isError: true);
    });
  }

  Future<void> _checkout(List<CartItemModel> cartItems, double total) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      utilsServices.showToast(message: 'Faça login para continuar', isError: true);
      return;
    }

    final WriteBatch batch = _firestore.batch();
    final DocumentReference orderRef = _firestore.collection('orders').doc();

    batch.set(orderRef, {
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending_payment',
      'totalAmount': total,
      'items': cartItems.map((cartItem) {
        return {
          'productId': cartItem.item.id,
          'productName': cartItem.item.itemName,
          'price': cartItem.item.price,
          'quantity': cartItem.quantity,
          'imageUrl': cartItem.item.imgUrl,
        };
      }).toList(),
    });
    
    for (var cartItem in cartItems) {
      final cartItemRef = _firestore.collection('users').doc(userId).collection('cart').doc(cartItem.item.id);
      batch.delete(cartItemRef);
    }

    try {
      await batch.commit();

      final orderForDialog = OrderModel(
        id: orderRef.id,
        createdDateTime: DateTime.now(),
        overdueDateTime: DateTime.now().add(const Duration(minutes: 15)),
        items: cartItems,
        status: 'pending_payment',
        copyAndPaste: 'PIX_GERADO_AQUI_${orderRef.id}',
        total: total,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => PaymentDialog(order: orderForDialog),
      );
    } catch (e) {
      utilsServices.showToast(message: 'Falha ao concluir o pedido. Tente novamente.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      // --- DEBUG 1 ---
      print('[CartTab] BUILD: Usuário não está logado. Exibindo tela de login.');
      return const Center(child: Text("Faça login para ver seu carrinho."));
    }

    // --- DEBUG 2 ---
    print('[CartTab] BUILD: Construindo a tela para o usuário: ${user.uid}');

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          // --- DEBUG 3 ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('[CartTab] STREAMBUILDER: Estado de conexão é "waiting".');
            return const Center(child: CircularProgressIndicator());
          }

          // --- DEBUG 4 ---
          if (snapshot.hasError) {
            print('[CartTab] STREAMBUILDER: Ocorreu um erro no stream! Erro: ${snapshot.error}');
            return Center(child: Text('Ocorreu um erro: ${snapshot.error}'));
          }

          // --- DEBUG 5 ---
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('[CartTab] STREAMBUILDER: O stream não retornou dados ou a lista de documentos está vazia.');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 40, color: CustomColors.customSwatchColor),
                  const Text('Não há itens no carrinho'),
                ],
              ),
            );
          }

          // --- DEBUG 6 ---
          print('[CartTab] STREAMBUILDER: Stream retornou ${snapshot.data!.docs.length} documento(s).');

          try {
            final List<CartItemModel> cartItems = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              
              // --- DEBUG 7 ---
              print('[CartTab] Mapeando documento: ID=${doc.id}, DADOS=${data}');

              return CartItemModel(
                item: ItemModel(
                  id: doc.id,
                  itemName: data['productName'] ?? 'Nome indisponível',
                  price: (data['price'] ?? 0.0).toDouble(),
                  imgUrl: data['imageUrl'] ?? '',
                  unit: data['unit'] ?? '',
                  description: data['description'] ?? '',
                ),
                quantity: data['quantity'] ?? 0,
              );
            }).toList();
            
            // --- DEBUG 8 ---
            print('[CartTab] Mapeamento para CartItemModel concluído com sucesso. Itens na lista: ${cartItems.length}');

            final double total = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice());

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (_, index) {
                      return CartTile(
                        cartItem: cartItems[index],
                        remove: (cartItem) => removeItemFromCart(cartItem.item.id),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 3, spreadRadius: 2)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Total geral', style: TextStyle(fontSize: 12)),
                      Text(
                        utilsServices.priceToCurrency(total, 2),
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
                          ),
                          onPressed: () async {
                            bool? result = await showOrderConfirmation();
                            if (result ?? false) {
                              _checkout(cartItems, total);
                            }
                          },
                          child: const Text('Concluir pedido', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } catch (e, stacktrace) {
            // --- DEBUG 9 ---
            print('[CartTab] ERRO CRÍTICO AO MAPEAR OS DADOS: $e');
            print('STACKTRACE: $stacktrace');
            return Center(child: Text('Erro ao processar dados do carrinho: $e'));
          }
        },
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
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Não')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }
}