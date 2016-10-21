AppBundleInfo = require('./AppBundleInfo')
stream = require('stream')
streamToBuffer = require('stream-to-buffer')
plist = require('plist')
bplist = require('bplist')
cgbiToPng = require('cgbi-to-png')

class iOSAppBundleInfo extends AppBundleInfo
  @::plistPath = 'Payload/*.app/Info.plist'
  constructor:(pathOrStream)->
    super(pathOrStream)
    @_infoLoaded = no
    @_info = {}
    @type = 'ios'

  _loadFileInfo:(callback)->
    if @_infoLoaded
      return callback()
    @findFileStream(@plistPath,(err,fileStream)=>
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

  loadInfo: (callback)->
    return @getPlist(callback)

  getPlist:(callback)->
    @_loadFileInfo (err)=>
      if err
        return callback(err)
      callback(null,@_info.plist)


  getIconFile: (callback) ->

    createSubNames = (initial, endname) ->
      [
        initial + '@3x' + endname + '.png'
        initial + '@2x' + endname + '.png'
      ]

    find = (index, lookup, cb) ->
      if !lookup[index]
        return cb(new Error('Icon not found'))
      self.findFileStream 'Payload/*.app/' + lookup[index], (err, stream) ->
        if err
          return find(index - 1, lookup, cb)
        if !stream
          return cb()
        cgbiToPng stream, cb
      return

    lookupType = (origin, lookup, cb) ->
      if origin and origin.CFBundlePrimaryIcon and origin.CFBundlePrimaryIcon.CFBundleIconFiles
        origin.CFBundlePrimaryIcon.CFBundleIconFiles.forEach (e) ->
          lookup = lookup.concat(createSubNames(e, ''))
          return
        return find(lookup.length - 1, lookup, cb)
      cb new Error('No icons found in plist for this type')

    if !@_info
      return callback(new Error('No plist found'))
    _plist = @_info.plist
    self = this
    lookupType _plist.CFBundleIcons, [], (err, datas) ->
      if err
        return lookupType(_plist['CFBundleIcons~ipad'], [ '*60x60@*.png' ], callback)
      callback err, datas
    return

  getIdentifier: ()->
    return @_info?.plist?.CFBundleIdentifier

  getName: ()->
    return @_info?.plist?.CFBundleDisplayName or @_info?.plist?.CFBundleName

  getVersionName: ()->
    return @_info?.plist?.CFBundleShortVersionString

  getVersionCode: ()->
    return @_info?.plist?.CFBundleVersion



module.exports = iOSAppBundleInfo