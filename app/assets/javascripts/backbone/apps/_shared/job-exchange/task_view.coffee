@AlumNet.module 'Shared.Views.JobExchange', (JobExchange, @AlumNet, Backbone, Marionette, $, _) ->
  class JobExchange.Task extends Marionette.CompositeView

    initialize: (options)->
      @mode = options.mode


    templateHelpers: ->
      model = @model

      arraySkill = @model.get('nice_have_attributes')
      arraySkill = _.where(arraySkill, {custom_field: "alumnet_skills"});
      arraySkill = _.pluck(arraySkill,'value');

      arraySkillRequired = @model.get('must_have_attributes')
      arraySkillRequired = _.where(arraySkillRequired, {custom_field: "alumnet_skills"});
      arraySkillRequired = _.pluck(arraySkillRequired,'value');

      skills = arraySkill.concat arraySkillRequired

      canInvite: @model.canInvite()
      canEdit: @model.canEdit()
      canDelete: @model.canDelete()
      canApply: @model.canApply()
      location: ->
        location = []
        location.push model.get('country').name unless model.get('country').name == ""
        location.push model.get('city').name unless model.get('city').name == ""
        location.join(', ')
      arraySkill: skills


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

    _showModal: ()->
      modal = new JobExchange.ModalApply

      modal.on "submit", @_apply, @

      $('#container-modal-apply').html(modal.render().el)


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
      # @ui.applyLink.attr("disabled", "disabled")
      @_showModal()


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


    _apply: (dataFromModal)->
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
              Backbone.ajax ##TODO: Refactor this :yondri (line 101 -> 113)
                url: AlumNet.api_endpoint + '/job_exchanges/' + @model.id + '/apply'
                method: 'PUT'
                data: dataFromModal
                success: ->
                  view.model.set('user_can_apply', false)
                  view.render()
                  $.growl.notice({ message: 'Your application has been sent successfully' })

            else
              AlumNet.navigate("premium?members_only", {trigger: true})
          else
            Backbone.ajax
              url: AlumNet.api_endpoint + '/job_exchanges/' + @model.id + '/apply'
              method: 'PUT'
              data: dataFromModal
              success: ->
                view.model.set('user_can_apply', false)
                view.render()
                $.growl.notice({ message: 'Your application has been sent successfully' })

        error: (data) =>
          $.growl.error({ message: 'Unknow error, please try again' })


  class JobExchange.ModalApply extends Backbone.Modal
    template: 'job_exchange/_shared/templates/modal_apply'

    cancelEl: '#js-close'
    submitEl: '#js-submit'
    keyControl: false

    templateHelpers: ()->
      profile = @model.profile
      last_experience: profile.get('last_experience')

    initialize: ()->
      @model = AlumNet.current_user

    submit: ()->
      data = Backbone.Syphon.serialize @
      @trigger "submit", data


