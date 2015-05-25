@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Post extends Backbone.Model
    initialize: ->
      @comments = new Entities.CommentsCollection
      @comments.url = AlumNet.api_endpoint + '/posts/' + @get('id') + '/comments'

      @on 'change', ->
        @comments.url = AlumNet.api_endpoint + '/posts/' + @get('id') + '/comments'
        @setPictures()

      unless @isNew()
        @setPictures()

    validation:
      body:
        required: true

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

    sumLike: ->
      count = @get('likes_count')
      @set('likes_count', count + 1)
      @set('you_like', true)

    remLike: ->
      count = @get('likes_count')
      @set('likes_count', count - 1)
      @set('you_like', false)

  # class Entities.PostCollection extends Backbone.Collection
  class Entities.PostCollection extends Backbone.PageableCollection
    model: Entities.Post

    state: 
      pageSize: 2
      currentPage: 1

    # initialize: ->
    #   @perPaginate: 2 #default value

    #Overriding method for Infinite pagination
    parseLinks: (resp, xhr)->      
      nextLink = if resp.length >= @state.pageSize then @url else null
      response = 
        first: "null" #this is only because the plugin require it as a string
        prev: "null" #this is only because the plugin require it as a string
        # next: @url        
        next: nextLink
  

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

    getNewPostForCurrentUser: ->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/me/posts'
      post

  AlumNet.reqres.setHandler 'post:event:new',(event_id)->
    API.getNewPostForEvent(event_id)

  AlumNet.reqres.setHandler 'post:group:new',(group_id)->
    API.getNewPostForGroup(group_id)

  AlumNet.reqres.setHandler 'post:user:new',(user_id)->
    API.getNewPostForUser(user_id)

  AlumNet.reqres.setHandler 'post:new',(postable, postable_id)->
    API.getNewPostFor(postable, postable_id)