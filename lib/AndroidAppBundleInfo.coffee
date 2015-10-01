AppBundleInfo = require('./AppBundleInfo')
stream = require('stream')
streamToBuffer = require('stream-to-buffer')
apkParser = require('apk-parser2')
BinaryXML = require('./BinaryXML')

class AndroidAppBundleInfo extends AppBundleInfo
  constructor:(filePathOrStream)->
    super filePathOrStream
    @_infoLoaded = no
    @_info = {}

  _loadFileInfo:(callback)->
    if @_infoLoaded
      return callback()
    @_findFileStream(/^AndroidManifest.xml$/,(err,fileStream)=>
      return callback(err) if err
      streamToBuffer(fileStream,(err,data)=>
        bxml = new BinaryXML(data)
        @_info.manifest = bxml.simpleParse().manifest
        @_infoLoaded = yes
        callback()
      )
    )


  getManifest:(callback)->
    @_loadFileInfo (err)=>
      if err
        return callback(err)
      callback(null,@_info.manifest)


  getIconFile:(callback)->
    @_findFileStream(/^drawable-*\/ic_launcher.png$/,callback)



module.exports = AndroidAppBundleInfo