library flutter_app_host;

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

final ANDROID_BASE_PATH = p.join('build', 'app', 'outputs', 'apk');

void main(List<String> arguments) async {
  if (arguments.length >= 2) {
    if ((arguments[0] != 'apk') && (arguments[0] != 'ipa')) {
      print('Manual upload type (first argument) must be "apk" or "ipa".');
      return;
    }
    final platform = (arguments[0] == 'apk') ? 'android' : 'ios';
    final version = arguments[1];
    if (arguments.length < 3) {
      print('Manual upload must specify filename argument.');
      return;
    }
    final filename = arguments[2];
    if (!(await File(filename).exists())) {
      print('Could not find file at ${filename}');
      return;
    }
    if ((platform == 'ios') && (arguments.length == 4)) {
      final ios_bundle_id = arguments[3];
      await do_upload(platform, filename, version, ios_bundle_id);
    } else {
      await do_upload(platform, filename, version);
    }
  } else if (arguments.length == 1) {
    if (arguments[0] == 'apk-release') {
      await do_android_upload('release');
    } else if (arguments[0] == 'apk-debug') {
      await do_android_upload('debug');
    } else {
      if ((arguments[0] == 'apk') || (arguments[0] == 'ipa')) {
        print('Manual upload must specify app version and filename arguments.');
      } else {
        print(
            'Upload type must be "apk-release", "apk-debug", "apk", or "ipa". Try the command without arguments to see options.');
      }
      return;
    }
  } else {
    print('Found the following application builds:');
    try {
      final release_info = await get_android_build_info('release');
      final release_version = release_info['apkInfo']['versionName'];
      print('\n* Android: release build, version ${release_version}');
      print('>> flutter packages pub run flutter_app_host apk-release');
    } catch (e) {}
    try {
      final debug_info = await get_android_build_info('debug');
      final debug_version = debug_info['apkInfo']['versionName'];
      print('\n* Android: debug build, version ${debug_version}');
      print('>> flutter packages pub run flutter_app_host apk-debug');
    } catch (e) {}

    print('\nManually upload Android build archives (.apk file):');
    print(
        '>> flutter packages pub run flutter_app_host apk <version> <filename>');

    print('\nManually upload iOS build archives (.ipa file):');
    print('https://flutter.dev/docs/deployment/ios#create-a-build-archive');
    print(
        '>> flutter packages pub run flutter_app_host ipa <version> <filename> <ios_bundle_identifier>');

    print('');
  }
}

do_android_upload(build_type) async {
  var build_info;
  try {
    build_info = await get_android_build_info(build_type);
  } catch (e) {
    print('Error! Could not find a ${build_type} build for Android.');
    return;
  }
  final file_path = p.join(ANDROID_BASE_PATH, build_type, build_info['path']);
  await do_upload('android', file_path, build_info['apkInfo']['versionName']);
}

get_android_build_info(dir_name) async {
  final info_filename = p.join(ANDROID_BASE_PATH, dir_name, 'output.json');
  final build_info = json.decode(await File(info_filename).readAsString());
  return build_info[0];
}

get_config() async {
  String config_file;
  try {
    config_file = await File('.apphost').readAsString();
  } catch (e) {
    print('Error! Could not find config file ".apphost", please create one.');
    rethrow;
  }
  var settings;
  try {
    settings = json.decode(config_file);
  } catch (e) {
    print('Error! Invalid settings file. Make sure it is JSON.');
    rethrow;
  }
  return settings;
}

void do_upload(String platform, String file_path, String version,
    [String ios_bundle_id]) async {
  final file_to_upload = File(file_path);
  var settings = await get_config();
  Map<String, String> url_params = {
    'user_id': settings['user_id'],
    'app_id': settings['app_id'],
    'key': settings['key'],
    'platform': platform,
    'version': version
  };
  if (platform == 'ios') {
    if ((ios_bundle_id == null) &&
        (settings.containsKey('ios_bundle_identifier')))
      ios_bundle_id = settings.ios_bundle_identifier;
    if (ios_bundle_id == null) {
      print(
          'Error: iOS bundle identifier must be specified as an argument, or included in your ".apphost" config file.');
      return;
    }
    url_params['ios_bundle_identifier'] = ios_bundle_id;
  }
  var uri = Uri.https('appho.st', 'api/get_upload_url', url_params);
  print('Fetching upload URL...');
  var response = await http.get(uri);
  String upload_url = response.body;
  if (!upload_url.startsWith('https:')) {
    throw 'Error fetching upload URL: ' + upload_url;
  }
  print('Uploading file...');
  final stream_request = http.StreamedRequest('PUT', Uri.parse(upload_url));
  stream_request.headers['Content-Type'] = 'application/octet-stream';
  stream_request.headers['Content-Length'] =
      (await file_to_upload.length()).toString();

  file_to_upload.openRead().listen((chunk) {
    stream_request.sink.add(chunk);
  }, onDone: () {
    stream_request.sink.close();
  });

  await stream_request.send();
  print('Upload complete! Install your app from:\n');

  Uri version_uri = Uri.https('appho.st', 'api/get_current_version/', {
    'u': settings['user_id'],
    'a': settings['app_id'],
    'platform': platform
  });
  final version_response = await http.get(version_uri);
  final version_info = json.decode(version_response.body);
  print(version_info['url']);
  print('');
}
