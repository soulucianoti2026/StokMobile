import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stokmobile/productPage/controllers/product_controllers.dart';
import 'package:stokmobile/productmodel/products_model.dart';
import 'package:stokmobile/shared/widgets/app_elavated_button.dart';

class ProductEditPage extends StatefulWidget {
  const ProductEditPage({super.key, required this.product});

  static const String route = '/productEdit';
  final Product product;

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  // 1. Criar os controladores
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    // 2. Inicializar os controladores com os dados originais do produto
    _nameController = TextEditingController(text: widget.product.name);
    // Para números, temos de converter para String no TextField
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _descController = TextEditingController(text: widget.product.description);
  }

  @override
  void dispose() {
    // 3. O Flutter exige que os controladores sejam "destruídos" quando se fecha o ecrã
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar produto'),
        shadowColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.grey.shade200,
          child: Consumer<Productcontrollers>(
            builder: (context, productCrontroller, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2),

                  child: Row(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(),
                        child: Image.network(
                          'http://163.176.170.134/uploads/teste/page teste/c07eef8c329949b5bd33c318e791f3be.png',
                        ),
                      ),
                      SizedBox(width: 9),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.product.category,
                              style: const TextStyle(
                                color: Color(0xFF0D9488),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            'Teclado Mecânico RGB',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'COD-001',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(width: 1.0, color: Colors.grey),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nome do produto'),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: widget.product.name,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preço'),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              hintText: widget.product.price.toString(),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estoque'),
                          TextField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              hintText: widget.product.stock.toString(),

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (valor) {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descrição'),
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: widget.product.description,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      textInputAction: TextInputAction.next,

                      onChanged: (valor) {},
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: AppElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        label: 'Cancelar',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Consumer<Productcontrollers>(
                        builder: (context, controller, child) {
                          return AppElevatedButton(
                            onPressed: () {
                              controller.updateProduct(
                                Product(
                                  code: widget.product.code,
                                  minimumStock: widget.product.minimumStock,

                                  name: _nameController.text,
                                  price:
                                      double.tryParse(_priceController.text) ??
                                      widget.product.price,
                                  stock:
                                      int.tryParse(_stockController.text) ??
                                      widget.product.stock,
                                  description: _descController.text,

                                  imageUrl: widget.product.imageUrl,
                                  category: widget.product.category,
                                  isActive: widget.product.isActive,
                                ),
                              );

                              Navigator.of(context).pop();
                            },
                            label: 'Salvar alterações',
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
