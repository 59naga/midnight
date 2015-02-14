gulp= require 'gulp'
gutil= require 'gulp-util'

Builder= require 'node-webkit-builder'
builder= new Builder
  appName: require('./package.json').name
  files: [
    './node_modules/coffee-script/**/*'
    './lib/**/*.*'
    './*.*'
  ]
  platforms: ['osx32','osx64','win32','win64']

gulp.task 'releases',->
  console.log process.env
  return if process.env.TRAVIS_TAG is undefined

  gulp.start 'zip'

gulp.task 'zip',['build'],->
  zip= require 'gulp-zip'

  streams= []
  for platform in builder.options.platforms
    streams.push do (platform)->
      gulp.src "./build/#{builder.options.appName}/#{platform}/**/*"
        .pipe zip "#{builder.options.appName}-#{platform}.zip"
        .pipe gulp.dest './build/'

  es= require 'event-stream'
  es.merge.apply es,streams

gulp.task 'build',->
  builder.build().catch (message)->
    throw new gutil.PluginError 'build:node-webkit-builder',message

# nw= null
# gulp.task 'default',->
#   gulp.start 'testWaiting'
#   gulp.watch '*.coffee',-> gulp.start 'testWaiting'
# gulp.task 'test',(callback)->
#   spawn= require('child_process').spawn
#   nw_bin= require('nw').findpath()
#   nw.kill()　if nw?
#   nw= spawn nw_bin,['.','-jasmine'],stdio:'inherit'
#   nw.on 'close',->
#     console.log ''
#     gutil.log 'closed nw-jasmine'
#     callback()
# gulp.task 'testWaiting',['test'],-> gutil.log 'Waiting for file changes before test...'

# via
# http://blog.anatoo.jp/entry/20140420/1397995711
# http://stackoverflow.com/questions/19227771/how-to-zip-a-directory-recursively-without-getting-malformed-files-when-you-tr
# http://efcl.info/2014/09/05/node-webkit-binary-release/
# http://efcl.info/2014/07/20/git-tag-to-release-github/
# http://qiita.com/todogzm/items/db9f5f2cedf976379f84
# https://github.com/azu/github-reader/blob/master/.travis.yml
# http://rcmdnk.github.io/blog/2014/09/08/computer-github-travis/