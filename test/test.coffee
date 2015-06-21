coffee      = require 'coffee-script/register'
moment      = require 'moment'
mocha       = require 'mocha'
rimraf      = require 'rimraf'
should      = require('chai').should()
exists      = require('fs').existsSync
join        = require('path').join
each        = require('lodash').each
_           = require('lodash')

Metalsmith  = require 'metalsmith'
plugin      = require '..'

describe 'metalsmith-archive', () ->

   beforeEach (done) ->
      rimraf 'build', done
   
   describe 'using default options', ()->
      
      it 'should generate tag pages', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['tagged/one/index.html']
               should.exist files['tagged/two/index.html']
               should.exist files['tagged/three/index.html']
               should.exist files['tagged/four/index.html']
               done()
   
      it 'should add allTags to metadata', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin()
            .use (files, metalsmith, done) ->
               metadata = metalsmith.metadata()
               metadata.allTags.should.exist
               metadata.allTags.length.should.be 
               done()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               done()
     
      it 'should add taggedPosts to each tag page', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['tagged/one/index.html' ].taggedPosts
               should.exist files['tagged/two/index.html' ].taggedPosts
               should.exist files['tagged/three/index.html' ].taggedPosts
               should.exist files['tagged/four/index.html' ].taggedPosts
               done()
   
      it 'should have correct number of taggedPosts', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               files['tagged/one/index.html' ].taggedPosts.length.should.equal 3
               files['tagged/two/index.html' ].taggedPosts.length.should.equal 1
               files['tagged/three/index.html' ].taggedPosts.length.should.equal 2
               files['tagged/four/index.html' ].taggedPosts.length.should.equal 1
               done()

      it 'should use default templates for pages', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               files['tagged/one/index.html' ].template.should.equal 'tag.jade'
               files['tagged/two/index.html' ].template.should.equal 'tag.jade'
               files['tagged/three/index.html' ].template.should.equal 'tag.jade'
               files['tagged/four/index.html' ].template.should.equal 'tag.jade'
               done()
   
      it 'should add files to taggedPosts', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               post = files['tagged/one/index.html'].taggedPosts[0]
               should.exist(post)
               post.title.should.equal 'test title'
               post.slug.should.equal 'test-slug'
               post.author.should.equal 'test-author'
               post.image.should.equal 'test.jpg'
               post.wordCount.should.equal 42
               post.readingTime.should.equal 2
               post.tags.length.should.equal 2
               done()
   
      it 'should handle tags with spaces in the name', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/tagsWithSpaces')
            .use plugin()
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               # console.log(files)
               should.exist files['tagged/one-two-three/index.html']
               # should.exist files['tagged/one-two-three/index.html']
               # files['tagged/one-two-three/index.html'].taggedPosts.length.should.equal 2
               done()
   
   describe 'using explicit options', ()->
      
      it 'should generate tag pages with specified urls', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin
               path: 'foo/:tag.html'
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['foo/one.html']
               should.exist files['foo/two.html']
               should.exist files['foo/three.html']
               should.exist files['foo/four.html']
               done()
   
      it 'should extract tags with custom field name', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/altTagName')
            .use plugin
               property: 'theseAreTheTags'
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               should.exist files['tagged/one/index.html' ]
               should.exist files['tagged/two/index.html' ]
               should.exist files['tagged/three/index.html' ]
               done()
   
      it 'should use specified template', (done)->
         
         Metalsmith(__dirname)
            .source('fixtures/src')
            .use plugin
               template: 'custom.hbs'
            .build (err, files) ->
               should.not.exist(err)
               should.exist(files)
               files['tagged/one/index.html' ].template.should.equal 'custom.hbs'
               files['tagged/two/index.html' ].template.should.equal 'custom.hbs'
               files['tagged/three/index.html' ].template.should.equal 'custom.hbs'
               files['tagged/four/index.html' ].template.should.equal 'custom.hbs'
               done()
