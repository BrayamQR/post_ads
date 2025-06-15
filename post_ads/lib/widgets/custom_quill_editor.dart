import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CustomQuillEditor extends StatefulWidget {
  final quill.QuillController controller;
  final FocusNode focusNode;
  final String? labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChange;
  final GlobalKey<FormFieldState>? formFieldkey;
  final bool? isRequired;
  final double fontSize;
  final Color? color;
  final AutovalidateMode? autovalidateMode;
  final bool showBoldButton;
  final bool showItalicButton;
  final bool showUnderLineButton;
  final bool showSmallButton;
  final bool showClipboardCopy;
  final bool showClipboardCut;
  final bool showClipboardPaste;
  final bool showDividers;
  final bool showRedo;
  final bool showUndo;
  final bool showListNumbers;
  final bool showListBullets;
  final bool showLink;
  final bool showSearchButton;
  final bool showStrikeThrough;
  final bool showInlineCode;
  final bool showColorButton;
  final bool showBackgroundColorButton;
  final bool showClearFormat;
  final bool showHeaderStyle;
  final bool showListCheck;
  final bool showCodeBlock;
  final bool showQuote;
  final bool showIndent;
  final bool showAlignmentButtons;
  final bool showFontFamily;
  final bool showFontSize;
  final bool showSubscript;
  final bool showSuperscript;
  final bool showDirection;
  final bool showLineHeightButton;

  const CustomQuillEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    this.labelText,
    this.isRequired,
    this.fontSize = 14,
    this.color = Colors.transparent,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.validator,
    this.onChange,
    this.formFieldkey,
    this.hintText = '',
    this.showBoldButton = false,
    this.showItalicButton = false,
    this.showUnderLineButton = false,
    this.showSmallButton = false,
    this.showClipboardCopy = false,
    this.showClipboardCut = false,
    this.showClipboardPaste = false,
    this.showDividers = false,
    this.showRedo = false,
    this.showUndo = false,
    this.showListNumbers = false,
    this.showListBullets = false,
    this.showLink = false,
    this.showSearchButton = false,
    this.showStrikeThrough = false,
    this.showInlineCode = false,
    this.showColorButton = false,
    this.showBackgroundColorButton = false,
    this.showClearFormat = false,
    this.showHeaderStyle = false,
    this.showListCheck = false,
    this.showCodeBlock = false,
    this.showQuote = false,
    this.showIndent = false,
    this.showAlignmentButtons = false,
    this.showFontFamily = false,
    this.showFontSize = false,
    this.showSubscript = false,
    this.showSuperscript = false,

    this.showDirection = false,
    this.showLineHeightButton = false,
  });

  @override
  State<CustomQuillEditor> createState() => _CustomQuillEditorState();
}

class _CustomQuillEditorState extends State<CustomQuillEditor> {
  bool _isFocused = false;
  final ScrollController _scrollController = ScrollController();
  bool get _hasFocus => widget.focusNode.hasFocus;
  bool get _hasText => !widget.controller.document.isEmpty();
  FormFieldState<String>? _fieldState;

  @override
  Widget build(BuildContext context) {
    return _buildCustomQuillEditor();
  }

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    });

    widget.controller.addListener(() {
      final plainText = widget.controller.document.toPlainText().trim();
      final deltaJson = widget.controller.document.toDelta().toJson();
      final jsonString = jsonEncode(deltaJson);
      _fieldState?.didChange(plainText);
      widget.onChange?.call(jsonString);
      setState(() {});
    });
  }

  Widget _buildCustomQuillEditor() {
    final bool floatLabel = _hasFocus || _hasText;

    return FormField<String>(
      key: widget.formFieldkey,
      validator: (_) {
        final plainText = widget.controller.document.toPlainText().trim();
        return widget.validator?.call(plainText);
      },
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String> field) {
        _fieldState = field;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: quill.QuillSimpleToolbar(
                controller: widget.controller,
                config: quill.QuillSimpleToolbarConfig(
                  showBoldButton: widget.showBoldButton,
                  showItalicButton: widget.showItalicButton,
                  showUnderLineButton: widget.showUnderLineButton,
                  showSmallButton: widget.showSmallButton,
                  showClipboardCopy: widget.showClipboardCopy,
                  showClipboardCut: widget.showClipboardCut,
                  showClipboardPaste: widget.showClipboardPaste,
                  showDividers: widget.showDividers,
                  showRedo: widget.showRedo,
                  showUndo: widget.showUndo,
                  showListNumbers: widget.showListNumbers,
                  showListBullets: widget.showListBullets,
                  showLink: widget.showLink,
                  showSearchButton: widget.showSearchButton,
                  showStrikeThrough: widget.showStrikeThrough,
                  showInlineCode: widget.showInlineCode,
                  showColorButton: widget.showColorButton,
                  showBackgroundColorButton: widget.showBackgroundColorButton,
                  showClearFormat: widget.showClearFormat,
                  showHeaderStyle: widget.showHeaderStyle,
                  showListCheck: widget.showListCheck,
                  showCodeBlock: widget.showCodeBlock,
                  showQuote: widget.showQuote,
                  showIndent: widget.showIndent,
                  showAlignmentButtons: widget.showAlignmentButtons,
                  showFontFamily: widget.showFontFamily,
                  showFontSize: widget.showFontSize,
                  showSubscript: widget.showSubscript,
                  showSuperscript: widget.showSuperscript,
                  showDirection: widget.showDirection,
                  showLineHeightButton: widget.showLineHeightButton,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            field.hasError
                                ? Colors.red.shade900
                                : _isFocused
                                ? Colors.deepPurple
                                : Colors.grey.shade800,
                        width: _isFocused ? 2.0 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding:
                        _isFocused
                            ? const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 14,
                            )
                            : const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 15,
                            ),
                    child: quill.QuillEditor(
                      focusNode: widget.focusNode,
                      scrollController: _scrollController,
                      controller: widget.controller,
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear,
                    left: floatLabel ? 8 : 8,
                    top: floatLabel ? -6 : 15,
                    child: Container(
                      color: Colors.grey.shade50,
                      padding:
                          widget.labelText != null
                              ? const EdgeInsets.symmetric(horizontal: 4)
                              : EdgeInsets.zero,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear,
                        style: TextStyle(
                          color:
                              field.hasError
                                  ? Colors.red.shade900
                                  : _isFocused
                                  ? Colors.deepPurple
                                  : Colors.grey.shade800,
                          fontSize:
                              floatLabel
                                  ? (widget.fontSize - 4)
                                  : widget.fontSize,
                          fontWeight: FontWeight.normal,
                        ),
                        child: Text(
                          widget.labelText.toString(),
                          style: TextStyle(
                            color:
                                field.hasError
                                    ? Colors.red.shade900
                                    : floatLabel
                                    ? Colors.deepPurple
                                    : Colors.grey.shade800,
                            fontSize:
                                floatLabel
                                    ? (widget.fontSize - 4)
                                    : widget.fontSize,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0, -0.3), // Aparece desde arriba
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      );
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child:
                        field.hasError
                            ? Padding(
                              key: const ValueKey('error'),
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                field.errorText!,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            )
                            : const SizedBox.shrink(key: ValueKey('no-error')),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: StreamBuilder(
                        stream: widget.controller.changes,
                        builder: (context, snapshot) {
                          final plainText =
                              widget.controller.document.toPlainText().trim();
                          final length = plainText.length;
                          return Text(
                            '$length caracteres',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
