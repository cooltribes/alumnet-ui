@AlumNet.module 'GroupsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'groups/shared/templates/header'
    templateHelpers: ->
      canEditInformation: @model.canDo('edit_group')
      userCanInvite: @model.userCanInvite()

    ui:
      'groupName':'#name'
    onRender: ->
      model = this.model
      @ui.groupName.editable
        type: "text"
        pk: model.id
        title: "Enter the name of Group"
        validate: (value)->
          if $.trim(value) == ""
            "this field is required"
        success: (response, newValue)->
          model.save({'name': newValue})


  class Shared.Layout extends Marionette.LayoutView
    template: 'groups/shared/templates/layout'
    templateHelpers: ->
      canEditInformation: @model.canDo('edit_group')
      userCanInvite: @model.userCanInvite()

    regions:
      header: '#group-header'
      body: '#group-body'

  API =
    getGroupLayout: (model)->
      new Shared.Layout
        model: model

    getGroupHeader: (model)->
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'group:layout', (model) ->
    API.getGroupLayout(model)

  AlumNet.reqres.setHandler 'group:header', (model)->
    API.getGroupHeader(model)