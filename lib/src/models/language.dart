class Language {
  String code;
  String englishName;
  String localName;
  String flag;
  bool selected;

  Language(this.code, this.englishName, this.localName, this.flag, {this.selected = false});
}

class LanguagesList {
  late List<Language> _languages;

  LanguagesList() {
    _languages = [
      Language("en", "English", "English", "assets/img/united-states-of-america.png"),
      Language("ar", "Arabic", "العربية", "assets/img/united-arab-emirates.png"),
      Language("es", "Spanish", "Spana", "assets/img/spain.png"),
      Language("fr", "French (France)", "Français - France", "assets/img/france.png"),
      Language("fr", "French (Canada)", "Français - Canadien", "assets/img/canada.png"),
      Language("pt", "Brazilian", "Brazilian", "assets/img/brazil.png"),
      Language("ko", "Korean", "Korean", "assets/img/united-states-of-america.png"),
    ];
  }

  List<Language> get languages => _languages;
}
