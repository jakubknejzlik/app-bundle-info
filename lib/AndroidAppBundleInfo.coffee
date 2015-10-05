AppBundleInfo = require('./AppBundleInfo')
stream = require('stream')
streamToBuffer = require('stream-to-buffer')
apkParser = require('apk-parser2')
BinaryXML = require('./BinaryXML')

class AndroidAppBundleInfo extends AppBundleInfo
  @::manifestPath = 'AndroidManifest.xml'
  constructor:(pathOrStream)->
    super(pathOrStream)
    @_infoLoaded = no
    @_info = {}
    @type = 'android'

  _loadFileInfo:(callback)->
    if @_infoLoaded
      return callback()
    @findFileStream(@manifestPath,(err,fileStream)=>
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
    @findFileStream('**/drawable-*/ic_launcher.png',callback)



module.exports = AndroidAppBundleInfo