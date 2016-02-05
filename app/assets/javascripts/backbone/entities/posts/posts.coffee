@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Post extends Backbone.Model
    initialize: ->
      @comments = new Entities.CommentsCollection
      @comments.url = AlumNet.api_endpoint + '/posts/' + @get('id') + '/comments'

      @likesCollection = new Entities.LikesCollection
      @likesCollection.url = AlumNet.api_endpoint + '/posts/' + @get('id') + '/likes'

      @likes = @get('likes') || []

      @on 'change', ->
        @comments.url = AlumNet.api_endpoint + '/posts/' + @get('id') + '/comments'
        @setPictures()

      unless @isNew()
        @setPictures()

    # validation:
    #   body:
    #     required: true

    bodyWithLinks: ->
      markup_body = @get 'markup_body'
      if markup_body
        mentionRE = /@\[([^\]]+)\]\(([^ \)]+)\)/g
        markup_body.replace mentionRE, (mention)->
          match = mentionRE.exec(mention)
          if match
            link = "<a href='#users/#{match[2]}/posts'>#{match[1]}</a>"
          else
            link = mention
          mentionRE.lastIndex = 0 #reset the regex because is global /g
          link
      else
        @get 'body'

    getModelContent: ->
      if @get('content')
        @modelContent = new Entities.Post @get('content') if @modelContent == undefined
        @modelContent

    firstLikeLinks: ->
      links = []
      if @get('likes_count') > 0
        if @get('you_like')
          links.push "You"
        for x in [1..3]
          like = @likes.shift()
          if like
            links.push "<a href='#users/#{like.user.id}/posts' title='#{like.user.name}'>#{like.user.name}</a>"
      links.join(", ")

    restLikeLink: ->
      link = false
      if @likes.length > 0
        num = @likes.length
        link = "<a href='#' class='js-show-likes' data-toggle='tooltip' data-placement='bottom' title='#{@restLikeList()}'>#{num} others</a>"
      link

    # TODO: hacer calculo de cuantos se van a mostrar y cuantos quedan :armando
    restLikeList: ->
      list = ""
      _.each @likes, (like)->
        list += "#{like.user.name}<br>"
      list

    setPictures: ->
      pictures = @get('pictures')
      if pictures
        @picture_collection = new Entities.PictureCollection pictures
      else
        @picture_collection = new Entities.PictureCollection

    infoLink: ->
      info = @get('postable_info')

      if info.type == "Group"
        url = "#groups/#{info.id}/posts"
        "in Group <a href='#{url}' title='#{info.name}'>#{info.name}</a>"
      else if info.type == "User"
        url = "#users/#{info.id}/posts"
        "in profile of <a href='#{url}' title='#{info.name}'>#{info.name}</a>"
      else if info.type == "Event"
        url = "#events/#{info.id}/posts"
        "in Event <a href='#{url}' title='#{info.name}'>#{info.name}</a>"
      else
        ""

    postUrl: ->
      info = @get('postable_info')

      if info.type == "Group"
        "#groups/#{info.id}/posts/#{@id}"
      else if info.type == "User"
        "#users/#{info.id}/posts/#{@id}"
      else if info.type == "Event"
        "#events/#{info.id}/posts/#{@id}"
      else
        ""

    tagsLinks: ->
      tags = @get('user_tags_list')
      array = []
      if tags.length > 0
        array = _.map tags, (user) ->
          "<a href='#users/#{user.id}/about'>#{user.name}</a>"
      array.join(', ')

    getArrayTags: (user) ->
      user.name

    sumLike: ->
      count = @get('likes_count')
      @set('likes_count', count + 1)
      @set('you_like', true)

    remLike: ->
      count = @get('likes_count')
      @set('likes_count', count - 1)
      @set('you_like', false)

    getUserLocation:->
      if @get("user").residence_city.name != "" && @get("user").residence_country.name != ""
        return "#{@get("user").residence_city.name} - #{@get("user").residence_country.name}"
      else
        if @get("user").residence_city.name == ""
          return "#{@get("user").residence_country.name}"
        else if @get("user").residence_country.name == ""
          return "No Location"
        else
          return "#{@get("user").residence_country.name}"

  class Entities.PostCollection extends Backbone.Collection
    model: Entities.Post
    rows: 12
    page: 1

  API =
    getNewPostForEvent: (event_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/events/' + event_id + '/posts'
      post

    getNewPostForGroup: (group_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/groups/' + group_id + '/posts'
      post

    getNewPostForUser: (user_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/users/' + user_id + '/posts'
      post

    getNewPostFor: (postable, postable_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + "/#{postable}/" + postable_id + '/posts'
      post

    findPost: (postable, postable_id, post_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + "/#{postable}/" + postable_id + '/posts'
      post.url = AlumNet.api_endpoint + "/#{postable}/" + postable_id + '/posts/' + post_id
      post

    getNewPostForCurrentUser: ->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/me/posts'
      post

    getAllPostForCurrentUser: ->
      post = new Entities.PostCollection
      # TODO: WHat is this!!! :rafael
      post.urlRoot = AlumNet.api_endpoint + '/me/posts?page=1$per_page=3'
      post

  AlumNet.reqres.setHandler 'post:event:new',(event_id)->
    API.getNewPostForEvent(event_id)

  AlumNet.reqres.setHandler 'post:group:new',(group_id)->
    API.getNewPostForGroup(group_id)

  AlumNet.reqres.setHandler 'post:user:new',(user_id)->
    API.getNewPostForUser(user_id)

  AlumNet.reqres.setHandler 'post:current',->
    API.getAllPostForCurrentUser()

  AlumNet.reqres.setHandler 'post:new',(postable, postable_id)->
    API.getNewPostFor(postable, postable_id)

  AlumNet.reqres.setHandler 'post:find',(postable, postable_id, post_id)->
    API.findPost(postable, postable_id, post_id)

