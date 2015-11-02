@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  ###### COMMENT VIEW
  class Posts.CommentView extends AlumNet.Shared.Views.CommentView
    className: 'groupPost__comment'

    templateHelpers: ->
      helpers =
        userCanComment: @postable.userIsMember()
      _.extend super(), helpers


  ###### POST VIEW
  class Posts.PostView extends AlumNet.Shared.Views.PostView
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-xs-12 col-sm-6 col-md-6'

    templateHelpers: ->
      helpers =
        userCanComment: @postable.userIsMember()
      _.extend super(), helpers


  ###### POST DETAIL
  class Posts.PostDetail extends Posts.PostView
    template: 'groups/posts/templates/post_detail'
    className: 'container margin_top_small'


  ###### POSTS COLLECTION
  class Posts.PostsView extends AlumNet.Shared.Views.PostsView
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    templateHelpers: ->
      helpers =
        userCanPost: @model.userIsMember()
        groupJoinProccess: @model.get('join_proccess')
        userHasMembership: @model.userHasMembership(AlumNet.current_user.id)
        groupIsClose: @model.isClose()

      _.extend super(), helpers

    events: ->
      events =
        'click .js-join': 'sendJoin'
      _.extend super(), events

    sendJoin:(e)->
      e.preventDefault()
      group = @model
      attrs = { group_id: group.id, user_id: AlumNet.current_user.id }
      request = AlumNet.request('membership:create', attrs)
      request.on 'save:success', (response, options)->
        AlumNet.trigger "groups:posts", group.id
      request.on 'save:error', (response, options)->
        console.log response.responseJSON

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.picture_ids = @picture_ids
      if data.body != ''
        @trigger 'post:submit', data
        view = @
        @picture_ids = []
        @ui.bodyInput.val('')
        @ui.fileList.html('')
        @ui.videoContainer.html('')
        @ui.tagsInput.select2('val', '')
        @ui.tagging.hide()