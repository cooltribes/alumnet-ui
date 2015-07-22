@AlumNet.module 'BusinessExchangeApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Profile extends Marionette.CompositeView
    className: 'container'

  class Shared.Task extends Marionette.CompositeView
    className: 'container'

    templateHelpers: ->
      model = @model
      canInvite: @model.canInvite()
      canEdit: @model.canEdit()
      canDelete: @model.canDelete()
      canApply: @model.canApply()
      location: ->
        location = []
        location.push model.get('country').text unless model.get('country').text == ""
        location.push model.get('city').text unless model.get('city').text == ""
        location.join(', ')
    ui:
      'deleteLink': '.js-job-delete'
      'refreshLink': '.js-job-refresh'
      'applyLink':'.js-job-apply'
      'inviteLink':'.js-job-invite'

    events:
      'click @ui.deleteLink': 'deleteClicked'
      'click @ui.refreshLink': 'refreshClicked'
      'click @ui.applyLink': 'applyClicked'
      'click @ui.inviteLink': 'inviteClicked'

    inviteClicked: (e)->
      e.preventDefault()
      user_id = $(e.currentTarget).data('user')
      task_id = $(e.currentTarget).data('task')
      invite = new AlumNet.Entities.TaskInvitation
      invite.save { user_id: user_id, task_id: task_id },
        success: ->
          $(e.currentTarget).remove()

    applyClicked: (e)->
      e.preventDefault()
      view = @

      url = AlumNet.api_endpoint + "/features/validate"
      current_user = AlumNet.current_user
      Backbone.ajax
        url: url
        type: "GET"
        data: { key_name: 'give_help' }
        success: (data) =>
          if data.validation
            if current_user.get('is_premium')
              Backbone.ajax
                url: AlumNet.api_endpoint + '/business_exchanges/' + @model.id + '/apply'
                method: 'PUT'
                success: ->
                  view.model.set('user_can_apply', false)
                  AlumNet.trigger('conversation:recipient', 'New Subject', view.model.getCreator())
            else
              AlumNet.navigate("premium?members_only", {trigger: true})
          else
            Backbone.ajax
              url: AlumNet.api_endpoint + '/business_exchanges/' + @model.id + '/apply'
              method: 'PUT'
              success: ->
                view.model.set('user_can_apply', false)
                AlumNet.trigger('conversation:recipient', 'New Subject', view.model.getCreator())

        error: (data) =>
          $.growl.error({ message: 'Unknow error, please try again' })

    refreshClicked: (e)->
      e.preventDefault()
      view = @
      @model.fetch
        url: AlumNet.api_endpoint + '/business_exchanges/' + @model.id + '/matches'
        success: ->
          view.render()

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        @model.destroy()