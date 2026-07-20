import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/showtime_repository.dart';

final showtimeFormControllerProvider =
    NotifierProvider<ShowtimeFormController, ShowtimeDraft?>(
      ShowtimeFormController.new,
    );

class ShowtimeFormController extends Notifier<ShowtimeDraft?> {
  @override
  ShowtimeDraft? build() => null;
  void setDraft(ShowtimeDraft draft) => state = draft;
}
