@AlumNet.module 'AdminApp.UsersCreate', (UsersCreate, @AlumNet, Backbone, Marionette, $, _) ->

  class UsersCreate.FormView extends Marionette.ItemView
    template: 'admin/users/create/templates/form'
    className: 'container'

    ui:
      'saveLink': '#js-save'
      'cancelLink': '#js-cancel'

    events:
      'click @ui.saveLink': 'saveClicked'
      'click @ui.cancelLink': 'cancelClicked'

    saveClicked: (e)->
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      ## TODO: create validations
      Backbone.ajax
        url: AlumNet.api_endpoint + "/admin/users/register"
        method: "post"
        data: data
        sucess: (data)->
          console.log data
        error: (data)->
          errors = data.responseJSON.errors
          _.each errors, (value, key, list)->
            view.showErrors(key, value[0])


    cancelClicked: (e)->
      e.preventDefault()
      AlumNet.trigger "admin:users"

    showErrors: (attr, error)->
      $el = @.$("[name=#{attr}]")
      $group = $el.closest('.form-group')
      $group.addClass('has-error')
      $group.find('.help-block').html(error).removeClass('hidden')

    clearErrors: (attr)->
      $el = @.$("[name=#{attr}]")
      $group = $el.closest('.form-group')
      $group.removeClass('has-error')
      $group.find('.help-block').html('').addClass('hidden')