yauzl = require('yauzl')
fs = require('fs-extra')
stream = require('stream')
tmp = require('tmp')
glob = require('glob')
Lock = require('lock')
fstream = require('fstream')
path = require('path')

class AndroidAppBundleInfo
  constructor:(@pathOrStream)->
    @extracted = no
    @lock = new Lock()
    @type = 'general'
    @tmpPath = null

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




  _extractContents:(_callback)->
    if @extracted
     return _callback()
    callback = (err)=>
      if not @tmpPath
        return _callback(err)
      fs.remove(@tmpPath,()->
        _callback(err)
      )
    @lock('extract',(release)=>
      callback = release(callback)
      @_getFilePath((err,zippath)=>
        return callback(err) if err
        tmp.dir((err,extractPath)=>
          return callback(err) if err
          @extractPath = extractPath
          yauzl.open(zippath, (err, zipfile)=>
            return callback(err) if err
            zipfile.on('error',callback)
            zipfile.on('entry',(entry)->
              if /\/$/.test(entry.fileName)
                return
              zipfile.openReadStream(entry,(err,readStream)->
                filePath = path.join(extractPath,entry.fileName)
                fs.ensureDir(path.dirname(filePath),(err)->
                  return callback(err) if err
                  readStream.pipe(fs.createWriteStream(filePath))
                )
              )
            )
            zipfile.on('close',()=>
              @extracted = yes
              callback()
            )
          )
        )
      )
    )

  _getFilePath:(callback)->
    if @pathOrStream instanceof stream.Readable
      tmp.file((err,file)=>
        return callback(err) if err
        @tmpPath = file
        @pathOrStream.pipe(fs.createWriteStream(file))
        .on('close',()->
          callback(null,file)
        ).on('error',callback)
      )
    else
      callback(null,@pathOrStream)

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