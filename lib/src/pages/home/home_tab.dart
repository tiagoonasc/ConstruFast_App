import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:add_to_cart_animation/add_to_cart_icon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teste/src/models/item_model.dart';
import 'package:teste/src/pages/home/components/item_tile.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GlobalKey<CartIconKey> globalKeyCartItems = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCardAnimation;

  Future<void> addToCart(ItemModel item) async {
    print('--- Tentando adicionar: ${item.itemName} (ID: ${item.id}) ---');

    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('--- Falha: Usuário não logado. ---');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para adicionar itens ao carrinho.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (item.id.isEmpty) {
      print('--- Falha: ID do item está vazio. ---');
      return;
    }

    final cartItemRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(item.id);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(cartItemRef);

        if (!doc.exists) {
          transaction.set(cartItemRef, {
            'quantity': 1,
            'productId': item.id,
            'productName': item.itemName,
            'price': item.price,
            'imageUrl': item.imgUrl,
            'unit': item.unit,
            'description': item.description,
          });
        } else {
          final currentQuantity = (doc.data()?['quantity'] ?? 0) as int;
          transaction.update(cartItemRef, {'quantity': currentQuantity + 1});
        }
      });
      print(
        '--- Sucesso: ${item.itemName} adicionado/atualizado no carrinho. ---',
      );
    } catch (e) {
      print('--- Falha na transação do Firestore: $e ---');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: const Text('Produtos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 15),
            child: GestureDetector(
              onTap: () {},
              child: AddToCartIcon(
                key: globalKeyCartItems,
                icon: const Icon(Icons.shopping_cart),
                // Se você tiver um badge, pode adicioná-lo aqui
              ),
            ),
          ),
        ],
      ),
      body: AddToCartAnimation(
        gkCart: globalKeyCartItems,
        previewDuration: const Duration(milliseconds: 100),
        previewCurve: Curves.ease,
        receiveCreateAddToCardAnimationMethod: (addToCardAnimationMethod) {
          runAddToCardAnimation = addToCardAnimationMethod;
        },
        child: Column(
          children: [
            // Campo de pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  hintText: 'Pesquise aqui...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 21),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(60),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
            ),

            // Grade de Produtos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('produtos')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar os produtos.'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Nenhum produto encontrado.'),
                    );
                  }
                  final List<ItemModel> loadedItems =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ItemModel(
                          id: doc.id,
                          itemName: data['itemName'] ?? 'Nome indisponível',
                          price: (data['price'] ?? 0.0).toDouble(),
                          imgUrl: data['imgUrl'] ?? '',
                          unit: data['unit'] ?? '',
                          description:
                              data['description'] ?? 'Descrição não informada.',
                        );
                      }).toList();

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    // Argumento obrigatório que estava faltando
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 9 / 11.5,
                        ),
                    itemCount: loadedItems.length,
                    itemBuilder: (_, index) {
                      return ItemTile(
                        item: loadedItems[index],
                        onAddToCart: (item, imageKey) {
                          addToCart(item);
                          runAddToCardAnimation(imageKey);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
