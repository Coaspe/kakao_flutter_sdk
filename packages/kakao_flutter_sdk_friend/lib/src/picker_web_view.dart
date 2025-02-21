import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_friend/src/localization_options.dart';
import 'package:kakao_flutter_sdk_friend/src/model/picker_friend_request_params.dart';
import 'package:kakao_flutter_sdk_friend/src/picker_alert.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PickerWebView extends StatefulWidget {
  final bool isSingle;
  final PickerFriendRequestParams params;

  const PickerWebView({Key? key, this.isSingle = false, required this.params})
      : super(key: key);

  @override
  State<PickerWebView> createState() => _PickerWebViewState();
}

class _PickerWebViewState extends State<PickerWebView> {
  static String domain = 'https://${KakaoSdk.hosts.picker}';
  static String sdkPath = 'flutter/sdk';
  static String singlePickerPath = 'select/single';
  static String multiPickerPath = 'select/multiple';
  static String initialUrl = '$domain/$sdkPath';

  late LocalizationOptions _localizationOptions;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool pickerShown = false;

  // In Android, onPageFinished() is called twice.
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();

    _localizationOptions = LocalizationOptions.getLocalizationOptions();

    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Stack(
            children: [
              WebView(
                zoomEnabled: false,
                initialUrl: initialUrl,
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: <JavascriptChannel>{
                  _pickerJavascriptChannel(context),
                  _alertJavascriptChannel(context),
                },
                onWebViewCreated: (WebViewController webViewController) =>
                    _controller.complete(webViewController),
                navigationDelegate: (NavigationRequest request) {
                  if (!request.url.contains(domain)) {
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
                onPageFinished: _onPageFinishedCallback,
                gestureNavigationEnabled: true,
                backgroundColor: const Color(0x00000000),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPageFinishedCallback(String url) {
    if (!pickerShown) {
      _controller.future.then((controller) {
        controller.runJavascript('Picker.postMessage("navigatePicker")');
      });
      pickerShown = true;
    } else if (url.contains('$domain/select')) {
      _controller.future.then((controller) {
        var javascript = """
          window.alert = function (e) {
            Alert.postMessage(e);
          }
        """;
        controller.runJavascript(javascript);
      });
    } else if (!isDisposed && url.contains('$domain/$sdkPath')) {
      isDisposed = true;
      var queryParameters = Uri.parse(url).queryParameters;
      if (queryParameters.isNotEmpty) {
        Navigator.of(context).pop(queryParameters);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  JavascriptChannel _pickerJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Picker',
      onMessageReceived: (JavascriptMessage message) async {
        if (message.message == "navigatePicker") {
          var path = widget.isSingle ? singlePickerPath : multiPickerPath;
          var url = '$domain/$path';
          var params = widget.params;

          String transId = generateRandomString(60);
          var pickerParams = {
            'transId': transId,
            'appKey': KakaoSdk.appKey,
            'ka': await KakaoSdk.kaHeader,
            'token': (await TokenManagerProvider.instance.manager.getToken())!
                .accessToken,
            'title': params.title,
            'enableSearch': params.enableSearch,
            'showMyProfile': params.showMyProfile,
            'showFavorite': params.showFavorite,
            'showPickedFriend': params.showPickedFriend,
            'maxPickableCount': params.maxPickableCount,
            'minPickableCount': params.minPickableCount,
            'enableBackButton': params.enableBackButton,
            'returnUrl': '$domain/$sdkPath',
          };
          pickerParams.removeWhere((k, v) => v == null);

          var javascript = '';
          javascript += _submitForm(url, pickerParams);
          await _controller.future
              .then((controller) => controller.runJavascript(javascript));
        }
      },
    );
  }

  JavascriptChannel _alertJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Alert',
      onMessageReceived: (JavascriptMessage message) {
        showDialog(
          context: context,
          builder: (context) => PickerAlert(
            title: widget.params.title ?? _localizationOptions.pickerTitle,
            message: message.message,
            confirm: _localizationOptions.confirm,
          ),
        );
      },
    );
  }

  String _submitForm(String url, Map<String, dynamic> pickerParams,
      {String? popupName = ''}) {
    return """
      const param = ${jsonEncode(pickerParams)}
      const form = document.createElement('form')
      form.setAttribute('accept-charset', 'utf-8')
      form.setAttribute('method', 'post')
      form.setAttribute('action', '$url')
      form.setAttribute('target', '$popupName')
      form.setAttribute('style', 'display:none')
      
      for(var key in param) {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = key
        input.value = param[key]
        form.appendChild(input)
      }
       
      document.body.appendChild(form);
      form.submit();
      document.body.removeChild(form);
    """;
  }
}
