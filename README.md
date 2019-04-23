# flutter_app_host

Integrate app distribution and over-the-air (OTA) installation into your Flutter workflow. This package allows you to directly upload your Android `.apk` and iOS `.ipa` packages to the AppHost hosting service. Then, simply share your app's private link with testers and enterprise app users.

## Example usage

Upload your latest Android release build to hosting:

`>> flutter packages pub run flutter_app_host apk-release`

Result:

```
Upload complete! Install your app from:

https://appho.st/d/#/d3Yg88ve
```

## Installation

1. Add `flutter_app_host` to `dev_dependencies` in your project's `pubspec.yaml` file
2. Sign up for a free account at https://appho.st
3. Enable the private upload API by going to the Dashboard page and generating an API key
4. Add an App to your account (set the name, logo, etc.)
5. On the page for your new app, scroll to the Private API section and download your config file
6. Rename the config file to `.apphost` and move it to the root of your local project directory (probably add it to your `.gitignore` too...)

## Usage

`>> flutter packages pub run flutter_app_host`

Displays a list of detected build outputs and the relevant commands to upload them:

```
Found the following application builds:

* Android: release build, version 1.1.0
>> flutter packages pub run flutter_app_host apk-release

* Android: debug build, version 1.1.0
>> flutter packages pub run flutter_app_host apk-debug

Manually upload Android build archives (.apk file):
>> flutter packages pub run flutter_app_host apk <version> <filename>

Manually upload iOS build archives (.ipa file):
https://flutter.dev/docs/deployment/ios#create-a-build-archive
>> flutter packages pub run flutter_app_host ipa <version> <filename> <ios_bundle_identifier>
```

## Configuration

The package relies on a configuration file `.apphost` in the directory its called from. This is a JSON document with the following structure:

```
{
  "user_id": "...",
  "app_id": "...",
  "key": "my_private_api_key...",
  "ios_bundle_identifier": "com.mycompany.myapp..."
}
```

The last field, `ios_bundle_identifier`, is optional. It can be used to avoid having to specify the bundle identifier when uploading iOS `.ipa` archives.