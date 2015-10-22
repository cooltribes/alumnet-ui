@AlumNet.module 'BusinessExchangeApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Profile extends Marionette.CompositeView
    template: 'business_exchange/_shared/templates/profile'

  class Shared.Task extends Marionette.CompositeView
    template: 'business_exchange/_shared/templates/discover_task'

    templateHelpers: ->
      model = @model
      canInvite: @model.canInvite()
      canEdit: @model.canEdit()
      canDelete: @model.canDelete()
      canApply: @model.canApply()
      daysRemaining: @model.daysRemaining()
      daysTotal: @model.totalDays()
      porcentdays: @progressbarPorcentaje()

      location: ->
        location = []
        location.push model.get('country').name unless model.get('country').name == ""
        location.push model.get('city').name unless model.get('city').name == ""
        location.join(',')
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
        data: { key_name: 'give_help' }
        success: (data) ->
          if data.validation
            if current_user.get('is_premium')
              view.sendApply()
            else
              AlumNet.navigate("premium?members_only", {trigger: true})
          else
            view.sendApply()
        error: (data) =>
          $.growl.error({ message: 'Unknow error, please try again' })

    sendApply: ->
      view = @
      Backbone.ajax
        url: AlumNet.api_endpoint + '/business_exchanges/' + @model.id + '/apply'
        method: 'PUT'
        success: ->
          model = view.model
          model.set('user_can_apply', false)
          AlumNet.trigger('conversation:recipient', model.get('name'), model.getCreator())

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

    progressbarPorcentaje: ->
      daysRemaining = @model.daysRemaining()
      daysTotal = @model.totalDays()
      daysPassed = daysTotal - daysRemaining
      if daysRemaining <= 0
        porcentdays = 100
      else
        porcentdays = (daysPassed / daysTotal) * 100
