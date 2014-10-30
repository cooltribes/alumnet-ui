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
    ui:
      'bodyInput': '#body'
    events:
      'click a#js-submit': 'submitClicked'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != ''
        this.trigger 'form:submit', data
        @ui.bodyInput.val('')



