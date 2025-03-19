import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final FormFieldValidator<String>? validator;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final Function(String?) onSearch;
  final TextEditingController? controller;
  final String? initialText;

  const SearchField({
    super.key,
    this.validator,
    this.labelText,
    this.hintText,
    this.helperText,
    required this.onSearch,
    this.controller,
    this.initialText,
  });

  @override
  SearchFieldState createState() => SearchFieldState();
}

class SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    _controller.text = widget.initialText ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(),
        hintText: widget.hintText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          onPressed: () => widget.onSearch(_controller.text),
          icon: Icon(Icons.search),
        ),
      ),
      onFieldSubmitted: widget.onSearch,
      validator: widget.validator,
    );
  }
}
