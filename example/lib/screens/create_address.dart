import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:okhi_flutter/models/okhi_usage_type.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter_example/widgets/full_button.dart';

class CreateAddress extends StatelessWidget {
  const CreateAddress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create an address"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: OkHiLocationManager(
                user: OkHiUser(
                  phone: "+254712000000",
                  email: "granson@okhi.co",
                ),
                configuration: OkHiLocationManagerConfiguration(
                  usageTypes: [UsageType.digitalVerification],
                ),
                onSucess: (response) {
                  _handleLocationManagerResponse(context, response);
                },
                onError: (error) {
                  if (kDebugMode) {
                    print(error.code);
                    print(error.message);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FullButton(
                title: "Go back",
                onPressed: () {
                  _handleOnButtonPress(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleOnButtonPress(BuildContext context) {
    Navigator.pop(context);
  }

  _handleLocationManagerResponse(
      BuildContext context, OkHiLocationManagerResponse response) {
    Navigator.pop(context, response);
  }
}
