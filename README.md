# app-bundle-info

[![Build Status](https://travis-ci.org/jakubknejzlik/app-bundle-info.svg?branch=master)](https://travis-ci.org/jakubknejzlik/app-bundle-info)

Get information from application bundle files (ipa (iOS) and apk (Android) are currently supported).

## iOS
Module is able to parse information from plist and get PNG icon file (currently the file is compressed with xcode).

## Android
Module is able to parse information from AndroidManifest and get PNG icon file.

# Example
You can get information from file or stream. If you don't know the type of bundle(specially when using streams), use autodetect function.

```
var AppBundleInfo = require('app-bundle-info')

AppBundleInfo.autodetect(ipaStream,function(err,bundleInfo){
    bundleInfo.loadInfo(function(err,information){

        if (bundleInfo.type == 'ios') {
            assert.equal(bundleInfo.getIdentifier(), information.CFBundleIdentifier)
            assert.equal(bundleInfo.getName(), information.CFBundleDisplayName || information.CFBundleName)
            assert.equal(bundleInfo.getVersionName(), information.CFBundleShortVersionString)
            assert.equal(bundleInfo.getVersionCode(), information.CFBundleVersion)
        } else if (bundleInfo.type == 'android') {
            assert.equal(bundleInfo.getIdentifier(), information.package)
            assert.equal(bundleInfo.getName(), information.package) // TODO: get application icon name
            assert.equal(bundleInfo.getVersionName(), information.versionName)
            assert.equal(bundleInfo.getVersionCode(), information.versionCode)
        }

    });
});
```

Or you can use OS specific methods directly:


```
var AppBundleInfo = require('app-bundle-info');
var fs = require('fs');

var bundleInfo = new AppBundleInfo.Android(apkStream)
bundleInfo.getManifest(function(err,manifestData){
    console.log(manifestData.package);
});
bundleInfo.getIcon(function(err,iconStream){
    iconStream.pipe(fs.createWriteStream('icon.png'));
});
```