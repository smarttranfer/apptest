import 'package:boilerplate/data/repository/user_repository.dart';
import 'package:boilerplate/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  UserRepository userRepository;

  // store for handling login errors
  final FormErrorStore loginErrorStore = FormErrorStore();

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  _LoginStore(this.userRepository) {
    _setupValidations();
  }

  // disposers:-----------------------------------------------------------------
  List<ReactionDisposer> _disposers;

  void _setupValidations() {
    _disposers = [
      reaction((_) => userEmail, validateUserEmail),
      reaction((_) => password, validatePassword),
    ];
  }

  // store variables:-----------------------------------------------------------
  @observable
  String userEmail = '';

  @observable
  String password = '';

  @observable
  bool success = false;

  @observable
  bool loading = false;

  @computed
  bool get canLogin =>
      !loginErrorStore.hasErrorsInLogin &&
      userEmail.isNotEmpty &&
      password.isNotEmpty;

  // actions:-------------------------------------------------------------------
  @action
  void setEmail(String value) {
    userEmail = value;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void validateUserEmail(String value) {
    if (value.isEmpty) {
      loginErrorStore.userEmail = "Vui lòng nhập địa chỉ E-mail";
    } else if (!isEmail(value)) {
      loginErrorStore.userEmail = "Địa chỉ E-mail chưa đúng định dạng";
    } else {
      loginErrorStore.userEmail = null;
    }
  }

  @action
  void validatePassword(String value) {
    if (value.isEmpty) {
      loginErrorStore.password = "Vui lòng nhập mật khẩu";
    } else if (value.length < 6) {
      loginErrorStore.password = "Mật khẩu phải có ít nhất 6 kí tự";
    } else {
      loginErrorStore.password = null;
    }
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}

class FormErrorStore = _FormErrorStore with _$FormErrorStore;

abstract class _FormErrorStore with Store {
  @observable
  String userEmail;

  @observable
  String password;

  @computed
  bool get hasErrorsInLogin => userEmail != null || this.password != null;
}
