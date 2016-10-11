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
            var abi = new AppBundleInfo.iOS(file.file);

            abi.getPlist(function(err,data){
                if(err)return cb(err);

                assert.equal(data.CFBundleVersion,file.version);
                assert.equal(data.CFBundleName,file.name);

                assert.equal(abi.getVersionCode(),file.version);
                assert.equal(abi.getName(),file.name);

                cb()
            });
        },done);
    })

    it('should load and parse Info.plist from stream',function(done){
        async.forEach(files,function(file,cb){
            var abi = new AppBundleInfo.iOS(fs.createReadStream(file.file));

            abi.getPlist(function(err,data){
                if(err)return cb(err);

                assert.equal(data.CFBundleVersion,file.version);
                assert.equal(data.CFBundleName,file.name);

                abi.getIconFile(function(err,iconData){
                    assert.ifError(err);
                    cb();
                })
            });
        },done);
    })

     it.only('should load and get the icon from ipa using the plist',function(done){
        this.timeout(5000);
        async.forEach(files,function(file,cb){
            var abi = new AppBundleInfo.iOS(file.file);

            abi.getPlist(function(err, data){
                if(err)return cb(err);

                abi.getIconFile(function(err, streamIcon) {
                    if(err) return cb(new Error("Cannot read icon from this iOS package"));
                    cb();
                });
            });
        },done);
    })

    it('should finish on invalid file',function(done){
        var abi = new AppBundleInfo.iOS(fs.createReadStream(__dirname+'/test.apk'));

        abi.getPlist(function(err){
            assert.ok(!!err);
            done();
        })
    })
})