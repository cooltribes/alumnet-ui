@AlumNet.module 'GroupsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'groups/shared/templates/header'
    templateHelpers: ->
      canEditInformation: this.model.canEditInformation()
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
    regions:
      header: '#group-header'
      body: '#group-body'

  initializeLayout = ->
    Shared.layout = new Shared.Layout

  initializeHeader = (model) ->
    Shared.header = new Shared.Header
      model: model

  API =
    getGroupLayout: ()->
      # Contarle a nelson que las vistas se destruyen. Por lo tanto no se puede usar la misma instancia
      # initializeLayout() if Shared.layout == undefined
      # Shared.layout
      new Shared.Layout

    getGroupHeader: (model)->
      # initializeHeader(model) if Shared.header == undefined
      # Shared.header
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'group:layout', ->
    API.getGroupLayout()

  AlumNet.reqres.setHandler 'group:header', (model)->
    API.getGroupHeader(model)