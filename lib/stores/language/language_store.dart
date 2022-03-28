import 'package:boilerplate/data/repository/repository.dart';
import 'package:boilerplate/models/language/Language.dart';
import 'package:boilerplate/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';

part 'language_store.g.dart';

class LanguageStore = _LanguageStore with _$LanguageStore;

abstract class _LanguageStore with Store {
  final Repository _repository;
  final ErrorStore errorStore = ErrorStore();

  List<Language> supportedLanguages = [
    Language(code: 'VN', locale: 'vi', language: 'Tiếng Việt'),
    Language(code: 'US', locale: 'en', language: 'English')
  ];

  // constructor:---------------------------------------------------------------
  _LanguageStore(Repository repository) : this._repository = repository {
    init();
  }

  // store variables:-----------------------------------------------------------
  @observable
  String locale = "vi";

  @computed
  String get currentLocale => locale;

  // actions:-------------------------------------------------------------------
  @action
  void changeLanguage(String value) {
    locale = value;
    _repository.changeLanguage(value).then((_) {
      // write additional logic here
    });
  }

  @action
  String getCode() {
    var code;

    if (locale == 'vi') {
      code = "VN";
    } else if (locale == 'en') {
      code = "US";
    }

    return code;
  }

  @action
  String getLanguage() {
    return supportedLanguages[supportedLanguages
            .indexWhere((language) => language.locale == locale)]
        .language;
  }

  // general:-------------------------------------------------------------------
  void init() async {
    _repository?.currentLanguage?.then((value) {
      if (value != null) {
        locale = value;
      }
    });
  }
}
