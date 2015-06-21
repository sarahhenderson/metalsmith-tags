metalsmith-tags
===============

A [Metalsmith](http://metalsmith.io) plugin that generates tag pages based on metadata in your files.

Usage
-----

The plugin expects your `tags` to be in comma delimited text field in your file metadata:

```markdown
---
title: My first file
tags: first, file, metalsmith
---
# This is my file content
```
You can also specify them as an array of values:
```markdown
---
title: My first file
tags: 
   - first
   - file
   - metalsmith
---
# This is my file content
```


```javascript
var archives = require('metalsmith-archives');
Metalsmith.use(tags());
```

This will pull all of the tag strings from your file metadata and generate a page for each unique tag.  The default template it will use is `tag.jade` and the default urls will be in the form `tagged/{tag}/index.html`.

If the tag has spaces in the name, these will be replaced by hyphens.  So if the file contains:
```yaml
tags: butterfly kisses
```
the generated tag page will be called `tagged/butterfly-kisses/index.html`.

On each tag page, the plugin will add a field named `taggedPosts` on the page containing all the posts with that tag.

You can then easily use that in your template to generate a list of posts:
```jade
   each post in taggedPosts
      a(href=post.path)= post.title
```

In addition, the original `tags` field in the file will be replaced with a collection of tag page objects, so you can link each tag to the tag page.

```jade
   each tag in tags
     a(href=tag.path)= tag.title
```

Finally, the plugin adds a `allTags` field to the Metalsmith metadata for you to use anywhere in the site.  This contains a collection of all the tag pages.  For instance, you could use this to generate a tag cloud in a sidebar.

The name of the metadata field, the url of the tag pages and the tag page template are all configurable:

```javascript
var tags = require('metalsmith-tags');

Metalsmith.use(tags({
   path: 'tag/:tag/index.html',
   property: 'post-tag',
   template: 'tag.hbs'
));

```


Tests
-----
   
   $ npm test
   
Licence
-------

GPLv2
