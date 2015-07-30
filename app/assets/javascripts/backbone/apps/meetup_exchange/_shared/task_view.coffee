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
      location: @model.get_location()
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
          $(e.currentTarget).parent().html('<div class="userCard__actions userCard__animation userCard__actions--Cancel">
              <span class="invitation">
                <span class="userCard__actions__text">INVITED</span>
                <span class="glyphicon glyphicon-user"></span>
                <span class="glyphicon glyphicon-ok"></span>
              </span>
            </div>')

    applyClicked: (e)->
      e.preventDefault()
      view = @
      Backbone.ajax
        url: AlumNet.api_endpoint + '/meetup_exchanges/' + @model.id + '/apply'
        method: 'PUT'
        success: ->
          view.model.set('user_can_apply', false)
          AlumNet.trigger('conversation:recipient', 'New Subject', view.model.getCreator())

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