class Product {
  final String code;
  final String name;
  final String imageUrl;
  final double price;
  final int stock;
  final String category;
  final String description;
  final bool isActive; // Novo campo baseado no "Produto ativo" da imagem

  Product({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.category,
    required this.description,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      // Se não vier no JSON, definimos como true (ativo) por padrão
      isActive: json['isActive'] ?? true,
    );
  }

  // Opcional: Um método para ajudar a transformar de volta em JSON
  // caso precise salvar o produto editado ou enviar para uma API.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'stock': stock,
      'category': category,
      'description': description,
      'isActive': isActive,
    };
  }
}
