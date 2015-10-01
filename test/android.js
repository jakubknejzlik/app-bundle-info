var AppBundleInfo = require('../index')
var assert = require('assert')
var fs = require('fs')

describe('android',function(){
    it('should load and parse manifest from file',function(done){
        var abi = new AppBundleInfo.android(__dirname+'/test.apk');

        abi.getManifest(function(err,data){
            if(err)return done(err);

            assert.equal(data.versionCode,1);
            assert.equal(data.versionName,'1.0');
            assert.equal(data.package,'com.octo.android.robodemo.sample');

            done()
        })

    })

    it('should load and parse manifest from stream',function(done){
        var abi = new AppBundleInfo.android(fs.createReadStream(__dirname+'/test.apk'));

        abi.getManifest(function(err,data){
            if(err)return done(err);

            assert.equal(data.versionCode,1);
            assert.equal(data.versionName,'1.0');
            assert.equal(data.package,'com.octo.android.robodemo.sample');

            done()
        })

    })

    it('should finish on invalid file',function(done){
        var abi = new AppBundleInfo.android(fs.createReadStream(__dirname+'/test.ipa'));

        abi.getManifest(function(err){
            assert.ok(!!err);
            done();
        })
    })
})