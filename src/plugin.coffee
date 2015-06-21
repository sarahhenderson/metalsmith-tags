_        = require 'lodash'
slugify  = require 'slugify'

module.exports = (options) ->
   
   options ?= {}
   defaults = 
      path: 'tagged/:tag/index.html'
      property: 'tags'
      template: 'tag.jade'

   _.defaults options, defaults


   newTag = (name, options) ->
      slug = slugify(name)
      path = options.path.replace(":tag", slug)
      tag =
         name: name
         title: name
         filename: path
         path: path 
         taggedPosts: []
         contents: ""
         template: options.template
   

   # links a post and a tag by adding each to the other's collection
   linkFileAndTag = (file, tag) ->
      tag.taggedPosts.push file
      file[options.property].push tag

   
   getTagByName = (tags, name) ->
       _.find _.values(tags), { name: name }
   
   # called iteratively as part of a reduce function
   extractTagObjects = (hash, value) ->
      # do not alter the result if we have no tag data
      return hash if not value?
      
      # if not already an array, split the strings by commas
      tagNames = if _.isArray(value) then value else value.split(',') 

      # create a new tag for each (trimmed) tag name
      tags = _.map tagNames, (tag) -> newTag(tag.trim(), options)

      # add each new tag to our result hash and return
      _.each tags, (tag) -> hash[tag.filename] = tag
      return hash


   # extract the individual trimmed tag names from a string
   extractTagNames = (value) ->
      return [] if not value?
      tagNames = if _.isArray(value) then value else value.split(',') 
      tags = _.map tagNames, (tag) -> tag.trim()
   

   (files, metalsmith, next) ->
      
      # pull all the tags from the files and turn them into objects
      tagStrings = _.pluck(_.values(files), options.property)
      tags = _.reduce tagStrings, extractTagObjects, {}
      
      # loop through each file to build its tags collection
      for filename of files
      
         # pull back the file data
         file = files[filename]
         
         # extract the tags as a string
         fileTagString = file[options.property]

         # we will replace the original string with a collection of tag objects
         file[options.property] = []
         
         # no need to continue if no tags property
         continue if not fileTagString?

         # split the tags into individual strings (if it isn't already)         
         tagNames = extractTagNames(fileTagString)
         
         # no need to continue if the list is empty
         continue if tagNames.length is 0

         for name in tagNames
            
            tag = getTagByName(tags, name)
            
            linkFileAndTag(file, tag)
                      
      # save those tag as global meta to use in navigations
      metadata = metalsmith.metadata()
      metadata.allTags = _.values(tags)
      
      # add the newly minted tag pages to the files collection
      _.extend files, tags 
         
      next()
