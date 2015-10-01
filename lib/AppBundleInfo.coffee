unzip = require('unzip')
fs = require('fs')
stream = require('stream')
streamToBuffer = require('stream-to-buffer')

class AndroidAppBundleInfo
  constructor:(@filePathOrStream)->

  _getFileStream:(callback)->
    if @filePathOrStream instanceof stream.Readable
      callback(null,@filePathOrStream)
    else
      callback(null,fs.createReadStream(@filePathOrStream))

  _findFileStream:(matchFile,callback)->
    @_getFileStream (err,fileStream)=>
      if err
        return callback(err)
      foundFile = null
      fileStream.pipe(unzip.Parse()).on("entry", (entry) =>
        if not foundFile and ((matchFile instanceof RegExp and matchFile.test(entry.path)) or matchFile is entry.path)
          foundFile = entry
          callback(null,entry)
        else
          entry.autodrain()
      ).on("error",callback)
      .on('close',()->
          if foundFile
            callback(null,foundFile)
          else
            callback(new Error('no file found'))
        )



module.exports = AndroidAppBundleInfo