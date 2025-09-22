import 'package:flutter/material.dart';
import 'package:front_erp_aromair/theme/colors.dart';
import 'package:front_erp_aromair/theme/text_style.dart';

class AromaAppBar extends AppBar {
  AromaAppBar({
    super.key,
    required String titleText,
    VoidCallback? onMenu,
    VoidCallback? onRefresh,
    List<Widget>? extraActions,
  }) : super(
         backgroundColor: AppColors.primary,
         elevation: 0,
         centerTitle: true,
         title: Text(
           titleText,
           style: AromaText.h2.copyWith(color: Colors.white),
         ),
         leading: Builder(
           builder: (ctx) => IconButton(
             icon: const Icon(Icons.menu, color: Colors.white),
             onPressed: onMenu ?? () => Scaffold.of(ctx).openDrawer(),
           ),
         ),
         actions: [
           if (onRefresh != null)
             IconButton(
               icon: const Icon(Icons.refresh, color: Colors.white),
               onPressed: onRefresh,
               tooltip: "Actualiser",
             ),
           ...?extraActions,
         ],
       );
}
