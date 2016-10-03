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

  loadInfo: (callback)->
    return @getManifest(callback)

  getManifest:(callback)->
    @_loadFileInfo (err)=>
      if err
        return callback(err)
      callback(null,@_info.manifest)


  getIconFile:(callback)->
    find = (index, cb) =>
      if !lookupOrdered[index]
        return cb(new Error('Icon not found'))
      path = lookupOrdered[index]
      @findFileStream path, (err, datas) ->
        if err then find(index + 1, cb) else cb(null, datas)

    lookupOrdered = [
      '**/mipmap-xxxhdpi*/ic_launcher.png'
      '**/drawable-xxxhdpi*/ic_launcher.png'
      '**/mipmap-xxhdpi*/ic_launcher.png'
      '**/drawable-xxhdpi*/ic_launcher.png'
      '**/mipmap-xhdpi*/ic_launcher.png'
      '**/drawable-xhdpi*/ic_launcher.png'
      '**/mipmap-hdpi*/ic_launcher.png'
      '**/drawable-hdpi*/ic_launcher.png'
      '**/mipmap-*/ic_launcher.png'
      '**/drawable-*/ic_launcher.png'
    ]
    find(0, callback)

  getIdentifier: ()->
    return @_info?.manifest?.package

  getName: ()->
    return @_info?.manifest?.package

  getVersionName: ()->
    return @_info?.manifest?.versionName

  getVersionCode: ()->
    return @_info?.manifest?.versionCode


module.exports = AndroidAppBundleInfo