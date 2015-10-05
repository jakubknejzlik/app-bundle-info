module.exports = AppBundleInfo = require('./lib/iOSAppBundleInfo')

module.exports.iOS = module.exports.ios = iOSBundleInfo = require('./lib/iOSAppBundleInfo')
module.exports.Android = module.exports.android = AndroidBundleInfo = require('./lib/AndroidAppBundleInfo')


module.exports.autodetect = (fileOrStream,callback)->
  abi = new AppBundleInfo(fileOrStream)
  abi.findFileStream(AndroidBundleInfo::manifestPath,(err,manifest)->
#    return callback(err) if err
    if manifest
      bi = new AndroidBundleInfo(null)
      bi.extracted = yes
      bi.extractPath = abi.extractPath
      return callback(null,bi)
    abi.findFileStream(iOSBundleInfo::plistPath,(err,plist)->
#      return callback(err) if err
      if plist
        bi = new iOSBundleInfo(null)
        bi.extracted = yes
        bi.extractPath = abi.extractPath
        return callback(null,bi)
      return callback(new Error('could not recognize bundle'))
    )
  )