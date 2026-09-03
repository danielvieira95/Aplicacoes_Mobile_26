// Criando a classe dish

class Dish {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imagePath;

  // Cria o construtor

  Dish(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.imagePath});

  // Metodo para tratar chave e valor

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath
    };
  }

  // Função para fazer a conversão de chave e valor

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        price: map['price'],
        imagePath: map['imagePath']);
  }

  // Função para converter para String
  @override
  String toString() {
    return 'Dish(id:$id,name:$name,description:$description,price:$price, imagePath:$imagePath)';
  }
}
