@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->

  class Posts.PostView extends Marionette.ItemView
    template: 'groups/posts/templates/post'
    className: 'post'
    templateHelpers: ->
      authorName: ->
        @user.name if @user != undefined
      authorAvatar: ->
        @user.avatar.thumb if @user != undefined



  class Posts.PostsView extends Marionette.CompositeView
    template: 'groups/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'

