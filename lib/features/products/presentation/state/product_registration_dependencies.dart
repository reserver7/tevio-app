import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_registration_analysis_repository.dart';
import '../../data/registration_media_picker.dart';

final registrationMediaPickerProvider = Provider<RegistrationMediaPicker>(
  (ref) => RegistrationMediaPicker(),
);

final productRegistrationAnalysisRepositoryProvider =
    Provider<ProductRegistrationAnalysisRepository>(
      (ref) => const MockProductRegistrationAnalysisRepository(),
    );
