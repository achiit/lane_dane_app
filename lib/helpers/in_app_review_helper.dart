import 'package:in_app_review/in_app_review.dart' as rv;
import 'package:lane_dane/utils/log_printer.dart';

class InAppReviewHelper {
  final logger = getLogger('InAppReviewHelper');
  final rv.InAppReview _inAppReview = rv.InAppReview.instance;
  void requestReview() async {
    if (await _inAppReview.isAvailable()) {
      logger.i('InAppReview is available');
      _inAppReview.requestReview();
    }
  }

  Future<void> openStoreListing() => _inAppReview.openStoreListing();
}
