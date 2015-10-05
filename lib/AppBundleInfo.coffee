unzip = require('unzip')
fs = require('fs-extra')
stream = require('stream')
streamToBuffer = require('stream-to-buffer')
tmp = require('tmp')
glob = require('glob')
Lock = require('lock')
fstream = require('fstream')

class AndroidAppBundleInfo
  constructor:(@pathOrStream)->
    @extracted = no
    @lock = new Lock()
    @type = 'general'

  clearContents:(callback)->
    callback = callback or ()->
    if @extracted
      fs.remove(@extractPath,(err)=>
        return callback(err) if err
        @extracted = no
        callback()
      )
    else
      callback()




  _extractContents:(callback)->
    if @extracted
      return callback()
    @lock('extract',(release)=>
      callback = release(callback)
      @_getFileStream((err,stream)=>
        return callback(err) if err
        tmp.dir((err,extractPath)=>
          return callback(err) if err
          @extractPath = extractPath
          writeStream = fstream.Writer(@extractPath)
#          console.log('extracting',@extractPath)
          stream.pipe(unzip.Parse())
            .pipe(writeStream)
            .on('close',()=>
              @extracted = yes
              callback()
            )
            .on('error',callback)
        )
      )
    )

  _getFileStream:(callback)->
    if @pathOrStream instanceof stream.Readable
      callback(null,@pathOrStream)
    else
      callback(null,fs.createReadStream(@pathOrStream))

  findFileStream:(matchFile,callback)->
    @_extractContents((err)=>
      return callback(err) if err
      searchPattern = @extractPath + '/' + matchFile
#      console.log(searchPattern)
      glob(searchPattern,(err,files)=>
        return callback(err) if err
        if files.length is 0
          return callback(new Error('no file found for \''+matchFile+'\''))
        callback(null,fs.createReadStream(files[0]))
      )
    )



module.exports = AndroidAppBundleInfo