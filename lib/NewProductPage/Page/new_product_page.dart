import 'package:flutter/material.dart';

class NewProductPage extends StatefulWidget {
  const NewProductPage({super.key});
  static const String route = '/NewProduct';

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final nomeController = TextEditingController();
  final skuController = TextEditingController();
  final estoqueMinimoController = TextEditingController(text: '3');
  final valorController = TextEditingController();

  // Opções da categoria, mock direto na classe por enquanto
  final categorias = ['Eletrônicos', 'Acessórios', 'Periféricos', 'Casa'];
  String categoriaSelecionada = 'Eletrônicos';

  // Número que aparece no contador
  int quantidade = 10;

  final estiloTitulo = TextStyle(
    //Vou compentizar depois
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade700,
  );

  InputDecoration estiloCampo({Widget? icone, String? prefixo}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      suffixIcon: icone,
      prefixText: prefixo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0D9488)),
      ),
    );
  }

  void salvar() {
    // Se nome ou código estiverem vazios, mostra um aviso e para
    if (nomeController.text.isEmpty || skuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e o código')),
      );
      return;
    }

    // Depois vamos salvar de verdade aqui

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Topo: botão voltar + título ----------
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Icon(Icons.chevron_left),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Novo Produto',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Cadastre um item no inventário',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text('Nome do Produto', style: estiloTitulo),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nomeController,
                      decoration: estiloCampo(),
                    ),
                    const SizedBox(height: 16),

                    Text('Código de barras / SKU', style: estiloTitulo),
                    const SizedBox(height: 6),
                    TextField(
                      controller: skuController,
                      // Atualiza a tela a cada letra, para mostrar a mensagem verde
                      onChanged: (texto) {
                        setState(() {});
                      },
                      decoration: estiloCampo(
                        icone: const Icon(Icons.qr_code_scanner),
                      ),
                    ),
                    if (skuController.text.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check,
                              size: 14,
                              color: Color(0xFF0D9488),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Código único disponível para uso corporativo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    Text('Categoria', style: estiloTitulo),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButton<String>(
                        value: categoriaSelecionada,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: categorias.map((categoria) {
                          return DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: (novoValor) {
                          setState(() {
                            categoriaSelecionada = novoValor!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lado esquerdo: contador
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Qtd Inicial', style: estiloTitulo),
                              const SizedBox(height: 6),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: () {
                                        if (quantidade > 0) {
                                          setState(() {
                                            quantidade--;
                                          });
                                        }
                                      },
                                    ),
                                    Text(
                                      '$quantidade',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          quantidade++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Lado direito: estoque mínimo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estoque Mínimo', style: estiloTitulo),
                              const SizedBox(height: 6),
                              TextField(
                                controller: estoqueMinimoController,
                                keyboardType: TextInputType.number,
                                decoration: estiloCampo(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text('Valor Unitário (R\$)', style: estiloTitulo),
                    const SizedBox(height: 6),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.number,
                      decoration: estiloCampo(prefixo: 'R\$ '),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey.shade800,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: salvar,
                      child: const Text(
                        'Salvar Produto',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
