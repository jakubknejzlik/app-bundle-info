var AppBundleInfo = require('../index')
var assert = require('assert')
var fs = require('fs')

describe('detect',function(){
    this.timeout(5000)
    it('should detect android',function(done){
        AppBundleInfo.autodetect(__dirname+'/test.apk',function(err,abi){
            assert.ifError(err);
            assert.equal(abi.type,'android');
            done()
        });
    })

    it('should detect ios',function(done){
        AppBundleInfo.autodetect(__dirname+'/test.ipa',function(err,abi){
            assert.ifError(err);
            assert.equal(abi.type,'ios');
            done()
        });
    })

})