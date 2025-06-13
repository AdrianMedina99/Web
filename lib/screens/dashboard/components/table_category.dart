import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../providers/CategoryProvider.dart';

class TableCategory extends StatefulWidget {
  const TableCategory({Key? key}) : super(key: key);

  @override
  State<TableCategory> createState() => _TableCategoryState();
}

class _TableCategoryState extends State<TableCategory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories());
  }

  void _openCategoryForm({Category? category}) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CategoryForm(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoryProvider>(context);
    if (provider.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Gestión de Categorías",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openCategoryForm(),
              icon: Icon(Icons.add),
              label: Text("Añadir Categoría"),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: defaultPadding,
            columns: const [
              DataColumn(label: Text("SVG y Nombre")),
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Acciones")),
            ],
            rows: provider.categories.map(
              (cat) => DataRow(
                onSelectChanged: (_) => _openCategoryForm(category: cat),
                cells: [
                  DataCell(
                    Row(
                      children: [
                        cat.svgContent.isNotEmpty
                            ? SvgPicture.network(cat.svgContent, width: 32, height: 32)
                            : Icon(Icons.image_not_supported, color: Colors.grey),
                        SizedBox(width: defaultPadding / 2),
                        Text(cat.title),
                      ],
                    ),
                  ),
                  DataCell(Text(cat.id)),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await provider.deleteCategory(cat.id);
                        if (provider.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${provider.error}')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class CategoryForm extends StatefulWidget {
  final Category? category;
  const CategoryForm({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  String? _svgContentRaw; // Contenido raw del SVG
  String? _svgUrl; // URL del SVG en storage
  bool _submitting = false;
  bool _svgChanged = false;
  String? _categoryId; // <-- Añadido para mantener el id

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.category?.title ?? '');
    _svgUrl = widget.category?.svgContent;
    _svgContentRaw = null;
    _categoryId = widget.category?.id; // <-- Guarda el id original
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickSvg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg'],
    );
    if (result != null) {
      final fileName = result.files.single.name;
      final ext = path.extension(fileName).toLowerCase();
      if (ext != '.svg') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona un archivo SVG.')),
        );
        return;
      }
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al leer el archivo.')),
        );
        return;
      }
      final content = String.fromCharCodes(bytes);
      setState(() {
        _svgContentRaw = content;
        _svgChanged = true;
        _svgUrl = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    try {
      if (_categoryId == null && widget.category != null) {
        _categoryId = widget.category!.id;
      }
      if (widget.category == null) {
        if (_svgContentRaw == null || _svgContentRaw!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Debes seleccionar un SVG.')),
          );
          setState(() => _submitting = false);
          return;
        }
        await provider.createCategory(_titleController.text, _svgContentRaw!);
      } else {
        if (_svgChanged && _svgContentRaw != null && _svgContentRaw!.isNotEmpty) {
          await provider.updateCategory(_categoryId!, _titleController.text, _svgContentRaw!);
        } else if (_svgUrl != null && _svgUrl!.isNotEmpty) {
          await provider.apiService.updateCategory(_categoryId!, {
            'title': _titleController.text,
            'svgContent': _svgUrl!,
          });
          await provider.fetchCategories();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Debes seleccionar un SVG.')),
          );
          setState(() => _submitting = false);
          return;
        }
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return Container(
      width: 400,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Editar Categoría" : "Añadir Categoría",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (isEdit)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    Text("ID: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.category!.id),
                  ],
                ),
              ),
            SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
                fillColor: bgColor,
                filled: true,
              ),
              validator: (v) => v == null || v.isEmpty ? "Introduce un título" : null,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickSvg,
                  icon: Icon(Icons.upload_file),
                  label: Text("Subir SVG"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade900,
                  ),
                ),
                SizedBox(width: 12),
                if (_svgChanged && _svgContentRaw != null && _svgContentRaw!.isNotEmpty)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.string(_svgContentRaw!),
                  )
                else if (_svgUrl != null && _svgUrl!.isNotEmpty)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.network(_svgUrl!),
                  ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  child: Text("Cancelar"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(isEdit ? "Actualizar" : "Añadir"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit ? Colors.orange.shade100 : Colors.green.shade100,
                    foregroundColor: isEdit ? Colors.orange.shade900 : Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
