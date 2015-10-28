@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  ###### COMMENT VIEW
  class Posts.CommentView extends AlumNet.Shared.Views.CommentView
    template: 'groups/posts/templates/comment'
    className: 'groupPost__comment'

    templateHelpers: ->
      helpers =
        userCanComment: @postable.userIsMember()
      _.extend helpers, super()


  ###### POST VIEW
  class Posts.PostView extends AlumNet.Shared.Views.PostView
    # template: 'groups/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-xs-12 col-sm-6 col-md-6'

    getTemplate: ->
      if @model.get('post_type') == 'share'
        '_shared/posts/templates/share'
      else
        'groups/posts/templates/post'

    templateHelpers: ->
      helpers =
        userCanComment: @postable.userIsMember()
      _.extend helpers, super()


  ###### POST DETAIL
  class Posts.PostDetail extends Posts.PostView
    template: 'groups/posts/templates/post_detail'
    className: 'container margin_top_small'


  ###### POSTS COLLECTION
  class Posts.PostsView extends AlumNet.Shared.Views.PostsView
    template: 'groups/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    templateHelpers: ->
      helpers =
        userCanPost: @model.userIsMember()
        groupJoinProccess: @model.get('join_proccess')
        userHasMembership: @model.userHasMembership(AlumNet.current_user.id)
        groupIsClose: @model.isClose()

      _.extend helpers, super()

    events: ->
      events =
        'click .js-join': 'sendJoin'
      _.extend events, super()

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