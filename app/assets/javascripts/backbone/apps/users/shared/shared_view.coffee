@AlumNet.module 'UsersApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'users/shared/templates/header'
    # templateHelpers: ->
    #   canEditInformation: @model.canEditInformation()
    #   canInvite: @model.userCanInvite()
    # ui:
    #   'groupName':'#name'
    # onRender: ->
    #   model = this.model
    #   @ui.groupName.editable
    #     type: "text"
    #     pk: model.id
    #     title: "Enter the name of Group"
    #     validate: (value)->
    #       if $.trim(value) == ""
    #         "this field is required"
    #     success: (response, newValue)->
    #       model.save({'name': newValue})


  class Shared.Layout extends Marionette.LayoutView
    template: 'users/shared/templates/layout'
    # templateHelpers: ->
      # canEditInformation: @model.canEditInformation()
      # canInvite: @model.userCanInvite()

    regions:
      header: '#user-header'
      body: '#user-body'

  API =
    getUserLayout: (model)->
      new Shared.Layout
        model: model

    getUserHeader: (model)->
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'user:layout', (model) ->
    API.getUserLayout(model)

  AlumNet.reqres.setHandler 'user:header', (model)->
    API.getUserHeader(model)