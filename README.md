# app-bundle-info

[![Build Status](https://travis-ci.org/jakubknejzlik/app-bundle-info.svg?branch=master)](https://travis-ci.org/jakubknejzlik/app-bundle-info)

Get information application bundle files (ipa (iOS) and apk (Android) are currently supported).

## iOS
Module is able to parse information from plist and get PNG icon file (currently the file is compressed with xcode).

## Android
Module is able to parse information from AndroidManifest and get PNG icon file.

# Example
You can get information from file or stream. If you don't know the type of bundle(specially when using streams), use autodetect function.

```
var AppBundleInfo = require('app-bundle-info')

AppBundleInfo.autodetect(ipaStream,function(err,bundleInfo){
    bundleInfo.getPlist(function(err,plistData){

        console.log(plistData.CFBundleName);

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