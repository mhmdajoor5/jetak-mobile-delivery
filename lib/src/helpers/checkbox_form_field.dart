import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {super.key, Widget? title,
      required BuildContext context,
      super.onSaved,
      super.validator,
      bool super.initialValue = false,
      bool autovalidate = false})
      : super(
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: state.hasError,
                title: title,
                value: state.value,
                onChanged: state.didChange,
                subtitle: state.hasError
                    ? Text(
                        state.errorText ?? "",
                        style: TextStyle(color: Colors.black54),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}
