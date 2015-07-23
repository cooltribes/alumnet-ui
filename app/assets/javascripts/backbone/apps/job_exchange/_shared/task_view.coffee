@AlumNet.module 'JobExchangeApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Task extends Marionette.CompositeView

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
          $(e.currentTarget).parent().html('<div class="userCard__actions userCard__animation userCard__actions--Cancel">
              <span class="invitation">
                <span class="userCard__actions__text">INVITED</span> 
                <span class="glyphicon glyphicon-user"></span>
                <span class="glyphicon glyphicon-ok"></span>
              </span>
            </div>')
          #$(e.currentTarget).remove()

    applyClicked: (e)->
      e.preventDefault()
      view = @
      url = AlumNet.api_endpoint + "/features/validate"
      current_user = AlumNet.current_user
      Backbone.ajax
        url: url
        type: "GET"
        data: { key_name: 'apply_for_a_job' }
        success: (data) =>
          if data.validation
            if current_user.get('is_premium')
              Backbone.ajax
                url: AlumNet.api_endpoint + '/job_exchanges/' + @model.id + '/apply'
                method: 'PUT'
                success: ->
                  view.model.set('user_can_apply', false)
                  view.render()
            else
              AlumNet.navigate("premium?members_only", {trigger: true})
          else
            Backbone.ajax
              url: AlumNet.api_endpoint + '/job_exchanges/' + @model.id + '/apply'
              method: 'PUT'
              success: ->
                view.model.set('user_can_apply', false)
                view.render()
        error: (data) =>
          $.growl.error({ message: 'Unknow error, please try again' })

    refreshClicked: (e)->
      e.preventDefault()
      view = @
      @model.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/' + @model.id + '/matches'
        success: ->
          view.render()

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        @model.destroy()