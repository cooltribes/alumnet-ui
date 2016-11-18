@AlumNet.module 'Shared.Views', (Views, @AlumNet, Backbone, Marionette, $, _) ->
  class Views.ShareModal extends Backbone.Modal
    template: '_shared/posts/templates/share_modal'
    cancelEl: '#close'

    regions:
      'contentRegion': '.content-container'

    initialize: (options)->
      @postsView = options.postsView
      @postable_type = "me"
      if @model.get('post_type') == 'share'
        @content = @model.getModelContent()
      else
        @content = @model

    events:
      'change #postable_type': 'changePostable'
      'click #share': 'clickedShare'

    onShow: ->
      contentView = new AlumNet.Shared.Views.ContentView
        model: @content
        previewMode: true
      @contentRegion.show(contentView)

    templateHelpers: ->
      model = @model
      permissions = @model.get('permissions')

      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      current_user_avatar: AlumNet.current_user.get('avatar').medium
      current_user_name: AlumNet.current_user.get('name')
      infoLink: @model.infoLink()
      tagsLinks: @model.tagsLinks()
      likesLinks: @model.firstLikeLinks()
      restLikeLink: @model.restLikeLink()

      pictures_is_odd: (pictures)->
        pictures.length % 2 != 0
      picturesToShow: ->
        if model.get('pictures').length > 5
          _.first(model.get('pictures'), 5)
        else
          model.get('pictures')

    changePostable: (e)->
      @postable_type = $(e.currentTarget).val()
      if @postable_type == "users"
        @usersSelect()
      else if @postable_type == "events"
        @eventsSelect()
      else if @postable_type == "groups"
        @groupsSelect()
      else if @postable_type == "me"
        @$('#postable_id').select2('destroy')

    clickedShare: (e)->
      e.preventDefault()
      view = @
      if @postable_type == "me"
        @postable_id = AlumNet.current_user.id
        post = AlumNet.request('post:new', 'users', @postable_id)
      else
        @postable_id = @$('#postable_id').select2('val')
        post = AlumNet.request('post:new', @postable_type, @postable_id)

      body = @$('textarea#body').val()
      data = { body: body, content_id: @content.id, content_type: 'Post' }
      post.save data,
        success: (model)->
          view.destroy()
          $.growl.notice({ message: 'The post has been shared successfully' })
        error: (model, response)->
          message = AlumNet.formatErrorsFromApi(response.responseJSON)
          $.growl.error(message: message)

    eventsSelect: ->
      @$('#postable_id').select2
        placeholder: "Select a Event"
        minimumInputLength: 2
        ajax:
          url: AlumNet.api_endpoint + "/users/#{AlumNet.current_user.id}/events"
          dataType: 'json'
          data: (term)->
            q:
              name_cont: term
          results: (resp, page) ->            
            results:
              resp.data
        formatResult: (data)->
          data.name
        formatSelection: (data)->
          data.name

    groupsSelect: ->
      @$('#postable_id').select2
        placeholder: "Select a Group"
        minimumInputLength: 2
        ajax:
          url: AlumNet.api_endpoint + "/users/#{AlumNet.current_user.id}/memberships/groups"
          dataType: 'json'
          data: (term)->
            q:
              group_name_cont: term
          results: (resp, page) ->             
            groups = _.map resp.data, (element)->
              element.group
            results:
              groups                       
        formatResult: (data)->
          data.name
        formatSelection: (data)->
          data.name

     usersSelect: ->
      @$('#postable_id').select2
        placeholder: "Select a Friend"
        minimumInputLength: 2
        ajax:
          url: AlumNet.api_endpoint + '/me/friendships/friends'
          dataType: 'json'
          data: (term)->
            q:
              m: 'or'
              profile_first_name_cont: term
              profile_last_name_cont: term
          results: (resp, page) ->            
            results:
              resp.data
        formatResult: (data)->
          data.name
        formatSelection: (data)->
          data.name
