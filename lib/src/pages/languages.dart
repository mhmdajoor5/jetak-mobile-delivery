import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/language.dart';
import '../repository/settings_repository.dart' as settingRepo;

class LanguagesWidget extends StatefulWidget {
  const LanguagesWidget({super.key});

  @override
  _LanguagesWidgetState createState() => _LanguagesWidgetState();
}

class _LanguagesWidgetState extends State<LanguagesWidget> {
 late LanguagesList languagesList;

  @override
  void initState() {
    languagesList = LanguagesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).languages,
          style: TextStyle(letterSpacing: 1.3),
        ),
        actions: <Widget>[
          ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Colors.black54),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.translate,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  S.of(context).app_language,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(S.of(context).select_your_preferred_languages),
              ),
            ),
            SizedBox(height: 10),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: languagesList.languages.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                Language language = languagesList.languages.elementAt(index);
                settingRepo.getDefaultLanguage(settingRepo.setting.value.mobileLanguage.value.languageCode).then((langCode) {
                  if (langCode == language.code) {
                    language.selected = true;
                  }
                });
                return InkWell(
                  onTap: () async {
                    settingRepo.setting.value.mobileLanguage.value = Locale(language.code, '');
                    settingRepo.setting.notifyListeners();
                    for (var _l in languagesList.languages) {
                      setState(() {
                        _l.selected = false;
                      });
                    }
                    language.selected = !language.selected;
                    settingRepo.setDefaultLanguage(language.code);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                image: DecorationImage(image: AssetImage(language.flag), fit: BoxFit.cover),
                              ),
                            ),
                            Container(
                              height: language.selected ? 40 : 0,
                              width: language.selected ? 40 : 0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                color: Colors.black54.withOpacity(language.selected ? 0.85 : 0),
                              ),
                              child: Icon(
                                Icons.check,
                                size: language.selected ? 24 : 0,
                                color: Colors.black54.withOpacity(language.selected ? 0.85 : 0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                language.englishName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                language.localName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
