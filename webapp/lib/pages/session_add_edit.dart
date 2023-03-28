import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import '../config.dart';
import '../models/sessions_model.dart';
import '../services/api_service.dart';

class SessionsAddEditDialog extends StatefulWidget {
  const SessionsAddEditDialog({Key? key, this.sessionModel, this.movieId})
      : super(key: key);
  final SessionsModel? sessionModel;
  final String? movieId;

  @override
  State<SessionsAddEditDialog> createState() => _SessionsAddEditDialogState();
}

class _SessionsAddEditDialogState extends State<SessionsAddEditDialog> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool isAPICallProcess = false;
  SessionsModel? sessionsModel;
  String? formattedDate;

  // late final String id;

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    sessionsModel = SessionsModel();
    if (widget.sessionModel?.date == null) {
      formattedDate = null;
      sessionsModel?.movieId = widget.movieId;
    } else {
      sessionsModel?.id = widget.sessionModel?.id;
      formattedDate = formatDate(widget.sessionModel!.date!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // insetPadding: EdgeInsets.only(top: 320, bottom: 320),
      title: Text('Sessão'),
      content: Form(
        key: globalKey,
        child: sessionForm(),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () async {
                if (vaidateAndSave()) {
                  setState(() {
                    isAPICallProcess = true;
                  });
                  if (widget.sessionModel?.id == null) {
                    APIService.saveSessions(sessionsModel!, false).then(
                      (response) {
                        setState(() {
                          isAPICallProcess = false;
                        });

                        if (response) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                        } else {
                          FormHelper.showSimpleAlertDialog(
                            context,
                            Config.appName,
                            "Error Occure",
                            "OK",
                            () {
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                    );
                  } else {
                    APIService.saveSessions(sessionsModel!, true).then(
                      (response) {
                        setState(() {
                          isAPICallProcess = false;
                        });

                        if (response) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
                        } else {
                          FormHelper.showSimpleAlertDialog(
                            context,
                            Config.appName,
                            "Error Occure",
                            "OK",
                            () {
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Salvar'),
            ),
          ),
        ),
      ],
    );
  }

  bool vaidateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget sessionForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: FormHelper.inputFieldWidget(
              // inputFormatters: [maskFormatter],
              context,
              initialValue: (formattedDate != null) ? formattedDate! : "",
              "date",
              "Data",
              isNumeric: true,
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return 'Data can´t be empty';
                }

                return null;
              },
              (onSavedVal) => {
                sessionsModel?.date =
                    DateFormat("MM/dd/yyyy").parse(onSavedVal).toString()
              },
              borderColor: Colors.black,
              borderFocusColor: Colors.black,
              textColor: Colors.black,
              hintColor: Colors.black.withOpacity(.7),
              borderRadius: 10,
              showPrefixIcon: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FormHelper.inputFieldWidget(
              context,
              "timeDay",
              "Hora",
              isNumeric: true,
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return 'Hourly can´t be empty';
                }
                return null;
              },
              (onSavedVal) => {
                sessionsModel?.timeDay = onSavedVal,
              },
              initialValue: widget.sessionModel?.timeDay ?? "",
              borderColor: Colors.black,
              borderFocusColor: Colors.black,
              textColor: Colors.black,
              hintColor: Colors.black.withOpacity(.7),
              borderRadius: 10,
              showPrefixIcon: false,
            ),
          ),
        ],
      ),
    );
  }
}
