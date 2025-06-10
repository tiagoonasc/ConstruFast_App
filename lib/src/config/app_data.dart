import 'package:teste/src/models/item_model.dart';

ItemModel cimento = ItemModel(
  description: 'Cimento Votoran o melhor para sua obra',
  imgUrl: 'assets/materiais/cimento.png',
  itemName: 'Cimento',
  price: 42.90,
  unit: 'RS',
);
ItemModel furadeira = ItemModel(
  description: 'Furadeira de auto rendimento',
  imgUrl: 'assets/materiais/furadeira.png',
  itemName: 'Furadeira',
  price: 239.90, 
  unit: 'RS',
);
ItemModel piso = ItemModel(
  description: 'Porcelanato retificado',
  imgUrl: 'assets/materiais/piso.png',
  itemName: 'Porcelanato',
  price: 80.90,
  unit: 'm2',
);
ItemModel tijolo = ItemModel(
  description: 'Tijolo catarina, sua paredes no padrao',
  imgUrl: 'assets/materiais/tijolo.png',
  itemName: 'Tijolo',
  price: 00.90,
  unit: 'RS',
);
ItemModel tinta = ItemModel(
  description: 'Sua obra com mais viva com as cores Suvinil',
  imgUrl: 'assets/materiais/tinta.png',
  itemName: 'Tinta',
  price: 630.00,
  unit: 'RS',
);
ItemModel torneira = ItemModel(
  description: 'Torneira Docol, garantia e qualidade compravadas',
  imgUrl: 'assets/materiais/torneira.png',
  itemName: 'Torneira',
  price: 357.90,
  unit: 'RS',
);

List<ItemModel> items = [
  cimento,
   furadeira,
    piso,
     tijolo,
      tinta,
       torneira
       ];

       List<String> categories = [
    'Materiais de construção',
    'Metais',
    'Pintura',
    'Pisos',
    'Ferramentas',
  ];
