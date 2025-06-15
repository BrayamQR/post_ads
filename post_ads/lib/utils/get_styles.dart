import 'package:flutter/material.dart';

Color getFormInputColor(GlobalKey<FormFieldState> key, FocusNode focusNode) {
  final state = key.currentState;
  if (state == null) return Colors.grey.shade800;
  if (state.hasError) return Colors.red.shade900;
  if (focusNode.hasFocus) return Colors.deepPurple;
  return Colors.grey;
}

Map<String, dynamic> getEstadoColor(int id) {
  late Color baseColor;

  switch (id) {
    case 1:
      baseColor = Colors.green;
      break;
    case 2:
      baseColor = Colors.orange;
      break;
    case 3:
      baseColor = Colors.red;
      break;
    case 4:
      baseColor = Colors.grey.shade500;
      break;
    default:
      baseColor = Colors.grey;
  }

  return {
    'color': baseColor,
    'shadow': BoxShadow(
      color: baseColor.withAlpha(150),
      blurRadius: 8,
      spreadRadius: 2,
    ),
  };
}

Widget infoRow(
  String label,
  String value, {
  Color? color,
  bool isBold = false,
  bool isEllipsis = false,
  double? fontSize,
  Widget? trailing, // Permite agregar un widget extra al final
  int? maxLines,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow:
                      isEllipsis ? TextOverflow.ellipsis : TextOverflow.visible,
                  maxLines: maxLines,
                  softWrap: !isEllipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 6), trailing],
            ],
          ),
        ),
      ],
    ),
  );
}

Icon getIconCategory(int id) {
  if (id == 1) {
    return Icon(Icons.work_sharp, color: Colors.indigo.shade300);
  } else if (id == 2) {
    return Icon(Icons.real_estate_agent_sharp, color: Colors.indigo.shade300);
  } else if (id == 3) {
    return Icon(Icons.price_change_sharp, color: Colors.indigo.shade300);
  } else {
    return Icon(Icons.monetization_on_sharp, color: Colors.indigo.shade300);
  }
}

String maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final visible = parts[0].length > 3 ? parts[0].substring(0, 3) : parts[0];
  final masked = '*' * (parts[0].length - visible.length);
  return '$visible$masked@${parts[1]}';
}
