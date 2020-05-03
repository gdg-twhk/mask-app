import 'package:flutter/material.dart';
import 'package:mask/models/api/mask.dart';
import 'package:mask/res/app_color.dart';
import 'package:mask/utils/app_localizations.dart';

class StoreListPage extends StatefulWidget {
  final List<Mask> masks;

  const StoreListPage(this.masks);

  @override
  _StoreListPageState createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  AppLocalizations app;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.storeList),
        backgroundColor: AppColors.blue,
      ),
      body: ListView.separated(
        itemBuilder: (_, index) {
          final mask = widget.masks[index];
          return InkWell(
            onTap: () {
              Navigator.pop(context, mask);
              // FA.logEvent('_click');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      mask.name,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 4.0,
                        ),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 3,
                            color: mask?.adultColor ?? AppColors.gray,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child:
                            Text("${app.maskAdult}: ${mask?.maskAdult ?? 0}"),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 4.0,
                        ),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 3,
                            color: mask?.childColor ?? AppColors.gray,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Text(
                            "${app.maskChildren}: ${mask?.maskChild ?? 0}"),
                      )
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${app.updateIn} ${mask?.beforeTime ?? ''}",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) {
          return Divider(
            color: AppColors.gray,
          );
        },
        itemCount: widget.masks.length,
      ),
    );
  }
}
