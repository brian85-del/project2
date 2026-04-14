import 'package:get/get.dart';
import 'package:expense_tracker/controllers/expenses_controllers.dart';
import 'package:expense_tracker/controllers/login_controllers.dart';
import 'package:expense_tracker/controllers/sign_up_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 1. The main Auth (Login/State)
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // 2. The specific Signup logic
    Get.lazyPut<SignupController>(() => SignupController(), fenix: true);

    // 3. Expenses
    Get.lazyPut<ExpenseController>(() => ExpenseController(), fenix: true);
  }
}
