@AlumNet.module 'MeetupExchangeApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Task extends Marionette.CompositeView
    className: 'container'

    initialize: (options)->
      @mode = options.mode

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
      Backbone.ajax
        url: AlumNet.api_endpoint + '/meetup_exchanges/' + @model.id + '/apply'
        method: 'PUT'
        success: ->
          view.model.set('user_can_apply', false)
          view.render()

    refreshClicked: (e)->
      e.preventDefault()
      view = @
      @model.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/' + @model.id + '/matches'
        success: ->
          view.render()

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        @model.destroy()