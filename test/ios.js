var AppBundleInfo = require('../index');
var assert = require('assert');
var fs = require('fs');
var async = require('async');

var files = [
    {file:__dirname+'/test.ipa',version:'0.1.2',name:'map-viewer'},
    {file:__dirname+'/test2.ipa',version:'1.3.21',name:'ci-test-app'}
]

describe('ios',function(){
    it('should load and parse Info.plist from file',function(done){
        async.forEach(files,function(file,cb){
            var abi = new AppBundleInfo.ios(file.file);

            abi.getPlist(function(err,data){
                if(err)return cb(err);

                assert.equal(data.CFBundleVersion,file.version);
                assert.equal(data.CFBundleName,file.name);

                cb()
            });
        },done);
    })

    it('should load and parse Info.plist from stream',function(done){
        async.forEach(files,function(file,cb){
            var abi = new AppBundleInfo.ios(fs.createReadStream(file.file));

            abi.getPlist(function(err,data){
                if(err)return cb(err);

                assert.equal(data.CFBundleVersion,file.version);
                assert.equal(data.CFBundleName,file.name);

                cb();
            });
        },done);
    })

    it('should finish on invalid file',function(done){
        var abi = new AppBundleInfo.ios(fs.createReadStream(__dirname+'/test.apk'));

        abi.getPlist(function(err){
            assert.ok(!!err);
            done();
        })
    })
})