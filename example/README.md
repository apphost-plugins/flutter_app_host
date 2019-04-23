## Show available commands

`>> flutter packages pub run flutter_app_host`

Output:

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

## Upload your most recent Android release build

`>> flutter packages pub run flutter_app_host apk-release`

Output:

```
Upload complete! Install your app from:

https://appho.st/d/#/d3Yg88ve
```

## Manually upload an Android app package

`>> flutter packages pub run flutter_app_host apk 1.2.1 my_app_file.apk`

## Manually upload an iOS app package

Flutter builds for iOS must be signed and archived from XCode before they can be distributed. See https://flutter.dev/docs/deployment/ios#create-a-build-archive for more information. Once you have your app package (`.ipa` file), use the following command to upload it. The last parameter, `ios_bundle_identifier`, should match the bundle identifier used by XCode to provision your app.

`>> flutter packages pub run flutter_app_host ipa 1.2.1 runner.ipa com.mycompany.appname`
