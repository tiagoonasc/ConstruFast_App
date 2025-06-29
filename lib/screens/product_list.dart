import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste/src/models/product_model.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final Stream<QuerySnapshot> _productsStream =
        FirebaseFirestore.instance.collection('produtos').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Produtos'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Algo deu errado.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          // Se tudo estiver certo, exibe a lista
          return ListView(
            children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Product product = Product.fromFirestore(document);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(
                        product.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold), 
                      ),
                      subtitle: Text(product.descricao),
                      trailing: Text(
                        'R\$ ${product.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
