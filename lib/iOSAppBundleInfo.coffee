AppBundleInfo = require('./AppBundleInfo')
stream = require('stream')
streamToBuffer = require('stream-to-buffer')
plist = require('plist')
bplist = require('bplist')

class iOSAppBundleInfo extends AppBundleInfo
  constructor:(filePathOrStream)->
    super filePathOrStream
    @_infoLoaded = no
    @_info = {}

  _loadFileInfo:(callback)->
    if @_infoLoaded
      return callback()
    @_findFileStream(/^Payload\/[^\/]+\.app\/Info.plist$/,(err,fileStream)=>
      return callback(err) if err
#      console.log('stream to buffer',fileStream)
      streamToBuffer(fileStream,(err,data)=>
#        console.log('stream to buffer gotit')
        @parsePlist(data, (err, plist) =>
          return callback(err) if err
          @_info.plist = plist
          @_infoLoaded = yes
          callback()
        )
      )
    )


  parsePlist:(data,callback)->
    if ('bplist00' != data.slice(0, 8).toString('ascii'))
      try
        callback(null,plist.parse(data.toString('utf-8')))
      catch e
        callback(e)
    else
      bplist.parseBuffer(data,(err,result)->
        return callback(err) if err
        callback(null,result[0])
      )

  getPlist:(callback)->
    @_loadFileInfo (err)=>
      if err
        return callback(err)
      callback(null,@_info.plist)


  getIconFile:(callback)->
    @_findFileStream(/^Payload\/[^\/]+\.app\/AppIcon60x60@.*\.png$/,callback)



module.exports = iOSAppBundleInfo