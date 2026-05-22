import 'package:photo_manager/photo_manager.dart';

/// Shared [PhotoManager] filter for listing device media.
///
/// Some OEM Android 9 MediaStore builds invalid SQL (`ORDER BY LIMIT …`)
/// when no sort column is provided. Always include [OrderOption]s.
final FilterOptionGroup kMediaAssetFilter = FilterOptionGroup(
  orders: <OrderOption>[
    OrderOption(type: OrderOptionType.createDate, asc: false),
  ],
);
