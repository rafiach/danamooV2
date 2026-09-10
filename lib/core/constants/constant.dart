import 'package:flutter/material.dart';

class Constant {
  // ================= COLORS - NEW DESIGN SYSTEM =================
  static const Color limeAccent = Color(0xFF84CC16);
  static const Color limeAccentLight = Color(0xFFA3E635);
  static const Color limeAccentDark = Color(0xFF65A30D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color bgNeutral = Color(0xFFFAFAFA);
  static const Color surfaceCard = Colors.white;
  static const Color borderSubtle = Color(0xFFE8E8E8);
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color expenseRedLight = Color(0xFFF87171);

  // ================= COLORS - BRAND (DEPRECATED - kept for backward compat) =================
  @Deprecated('Use limeAccent instead')
  static const Color primaryColor = Color(0xFF2196F3);
  @Deprecated('Use limeAccentLight instead')
  static const Color primaryLight = Color(0xFF64B5F6);
  @Deprecated('Use limeAccentDark instead')
  static const Color primaryDark = Color(0xFF1976D2);

  @Deprecated('Use limeAccent instead')
  static const Color secondaryColor = Color(0xFF03A9F4);
  @Deprecated('Use limeAccentLight instead')
  static const Color secondaryLight = Color(0xFF4FC3F7);
  @Deprecated('Use limeAccentDark instead')
  static const Color secondaryDark = Color(0xFF0288D1);

  @Deprecated('Use expenseRed instead')
  static const Color accentColor = Color(0xFFFF9800);

  static const Color greenPrime = Color(0xFF435859);
  static const Color greenLight = Color(0xFF607D7B);
  static const Color orange = Color(0xFFFAD0A8);

  static const Color incomePrime = Color(0xFF2EC4B6);
  static const Color incomeSecond = Color(0xFFE8F8F6);
  static const Color expensePrime = Color(0xFFFF9F1C);
  static const Color expenseSecond = Color(0xFFFFF4E6);
  static const Color foodsPrime = Color(0xFFFF7F50);
  static const Color foodsSecond = Color(0xFFFFF0EB);
  static const Color transportPrime = Color(0xFF3A86FF);
  static const Color transportSecond = Color(0xFFEEF4FF);
  static const Color shoppingPrime = Color(0xFF9B5DE5);
  static const Color shoppingSecond = Color(0xFFF5EEFF);
  static const Color billsPrime = Color(0xFFEF476F);
  static const Color billsSecond = Color(0xFFFFECEF);
  static const Color entertainPrime = Color(0xFF06D6A0);
  static const Color entertainSecond = Color(0xFFE9FBF6);
  static const Color healthPrime = Color(0xFFFF6B6B);
  static const Color healthSecond = Color(0xFFFFEDEE);
  static const Color otherPrime = Color(0xFF8D99AE);
  static const Color otherSecond = Color(0xFFF1F3F5);

  @Deprecated('Use bgNeutral/surfaceDark instead')
  static const Color violet50 = Color(0xFFEEEDFE);
  @Deprecated('Use bgNeutral/surfaceDark instead')
  static const Color violet200 = Color(0xFFAFA9EC);
  @Deprecated('Use limeAccent instead')
  static const Color violet400 = Color(0xFF7F77DD);
  @Deprecated('Use surfaceDark instead')
  static const Color violetDark = Color(0xFF534AB7);
  @Deprecated('Use surfaceDark instead')
  static const Color violetDarker = Color(0xFF3D1E6B);

  // ================= COLORS - BASIC =================
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static const Color blackPure = Colors.black;

  // ================= COLORS - GREY SCALE =================
  static const Color grey = Colors.grey;
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFFBDBDBD);
  static const Color greyDark = Color(0xFF616161);

  // ================= COLORS - STATUS =================
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);

  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // ================= COLORS - TEXT =================
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFE0E0E0);
  static const Color textWhite = Colors.white;

  // ================= COLORS - BACKGROUND =================
  static const Color bgPrimary = Colors.white;
  static const Color bgSecondary = Color(0xFFF5F5F5);
  static const Color bgTertiary = Color(0xFFEEEEE0);
  static const Color bgDark = Color(0xFF303030);

  // ================= COLORS - BORDER & DIVIDER =================
  static const Color borderColor = Color(0xFFE8E8E8);
  static const Color dividerColor = Color(0xFFE8E8E8);

  // ================= TEXT STYLES - HEADING =================
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  // ================= TEXT STYLES - BODY =================
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  // ================= TEXT STYLES - WEIGHT VARIANTS =================
  static const TextStyle textBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle textSemiBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle textMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle textRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle textLight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: textPrimary,
  );

  // ================= TEXT STYLES - SPECIAL =================
  static const TextStyle textUnderline = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    decoration: TextDecoration.underline,
  );

  static const TextStyle textItalic = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle textLineThrough = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  // ================= TEXT STYLES - BUTTON =================
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textWhite,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textWhite,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textWhite,
  );

  // ================= TEXT STYLES - CAPTION & LABEL =================
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 1.5,
  );

  // ================= SPACING - SQUARE (UNIVERSAL) =================
  static const SizedBox space4 = SizedBox.square(dimension: 4);
  static const SizedBox space8 = SizedBox.square(dimension: 8);
  static const SizedBox space12 = SizedBox.square(dimension: 12);
  static const SizedBox space16 = SizedBox.square(dimension: 16);
  static const SizedBox space20 = SizedBox.square(dimension: 20);
  static const SizedBox space24 = SizedBox.square(dimension: 24);
  static const SizedBox space32 = SizedBox.square(dimension: 32);
  static const SizedBox space40 = SizedBox.square(dimension: 40);
  static const SizedBox space48 = SizedBox.square(dimension: 48);
  static const SizedBox space64 = SizedBox.square(dimension: 64);

  // ================= SPACING - HEIGHT (VERTICAL) =================
  static const SizedBox height4 = SizedBox(height: 4);
  static const SizedBox height8 = SizedBox(height: 8);
  static const SizedBox height12 = SizedBox(height: 12);
  static const SizedBox height16 = SizedBox(height: 16);
  static const SizedBox height20 = SizedBox(height: 20);
  static const SizedBox height24 = SizedBox(height: 24);
  static const SizedBox height32 = SizedBox(height: 32);
  static const SizedBox height40 = SizedBox(height: 40);
  static const SizedBox height48 = SizedBox(height: 48);

  // ================= SPACING - WIDTH (HORIZONTAL) =================
  static const SizedBox width4 = SizedBox(width: 4);
  static const SizedBox width8 = SizedBox(width: 8);
  static const SizedBox width12 = SizedBox(width: 12);
  static const SizedBox width16 = SizedBox(width: 16);
  static const SizedBox width20 = SizedBox(width: 20);
  static const SizedBox width24 = SizedBox(width: 24);
  static const SizedBox width32 = SizedBox(width: 32);
  static const SizedBox width40 = SizedBox(width: 40);
  static const SizedBox width48 = SizedBox(width: 48);

  // ================= PADDING =================
  static const EdgeInsets paddingAll4 = EdgeInsets.all(4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(24);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(32);

  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets paddingH12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingH20 = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets paddingV12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets paddingV20 = EdgeInsets.symmetric(vertical: 20);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: 24);

  // ================= BORDER RADIUS =================
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXXLarge = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusRound = BorderRadius.all(Radius.circular(999));

  // ================= SHADOWS =================
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  @Deprecated('Use shadowSm/shadowMd/shadowLg instead')
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  @Deprecated('Use shadowMd instead')
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  @Deprecated('Use shadowLg instead')
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x24000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  // ================= DURATION =================
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 500);
}
