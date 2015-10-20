@AlumNet.module 'EventsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # LIKE MODAL
  class Posts.LikesModal extends AlumNet.Shared.Views.LikesModal

  ##### COMMENT VIEW
  class Posts.CommentView extends AlumNet.Shared.Views.CommentView
    template: 'events/posts/templates/comment'
    className: 'groupPost__comment'

    templateHelpers: ->
      helpers =
        userCanComment: @postable.userIsInvited()
      _.extend helpers, super()


  #### POST VIEW
  class Posts.PostView extends AlumNet.Shared.Views.PostView
    template: 'events/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-md-6'

    templateHelpers: ->
      helpers =
        userCanComment: @postable.userIsInvited()
      _.extend helpers, super()


  ###### POST DETAIL
  class Posts.PostDetail extends Posts.PostView
    template: 'events/posts/templates/post_detail'
    className: 'container margin_top_small'


  ##### POSTS COLLECTION
  class Posts.PostsView extends AlumNet.Shared.Views.PostsView
    template: 'events/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    templateHelpers: ->
      helpers =
        event_attendances: @model.get('attendances_count')
        event_going: @model.get('going_count')
        even_maybe: @model.get('maybe_count')
        even_not_goin: @model.get('not_going_count')
        userCanPost: @model.userIsInvited()
        eventIsClose: @model.isClose()

      _.extend helpers, super()

    ui:
      'bodyInput': '#body'
      'timeline': '#timeline'
      'fileList': '#js-filelist'
      'uploadLink': '#upload-picture'
      'tagsInput': '#js-user-tags-list'
      'tagging': '.tagging'
      'videoContainer': '#video_container'
      'preview_url': '#url'
      'preview_title': '#url_title'
      'preview_description': '#url_description'
      'preview_image': '#url_image'

    events: ->
      events =
        'click .js-join': 'sendJoin'
      _.extend events, super()

    sendJoin:(e)->
      e.preventDefault()
      event = @model
      current_user = AlumNet.current_user
      attrs = { event_id: event.id, user_id: current_user.id }
      request = AlumNet.request('membership:create', attrs)
      request.on 'save:success', (response, options)->
        AlumNet.trigger "events:posts", event.id
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