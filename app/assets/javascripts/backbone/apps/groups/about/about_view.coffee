@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.ItemView
    template: 'groups/about/templates/about'
    templateHelpers: ->
      canEditInformation: this.model.canEditInformation()
    ui:
      'groupDescription':'#description'
      'groupType': '#group_type'
    onRender: ->
      view = this
      @ui.groupDescription.editable
        type: "textarea"
        pk: view.model.id
        title: "Enter the description of Group"
        validate: (value)->
          if $.trim(value) == ""
            "this field is required"
        success: (response, newValue)->
          view.trigger "group:edit:description", view.model, newValue

      @ui.groupType.editable
        type: "select"
        pk: view.model.id
        title: "Enter the type of Group"
        source: [
          {value: 0, text: "Open"}
          {value: 1, text: "Closed"}
        ]
        validate: (value)->
          if $.trim(value) == ""
            "this field is required"
        success: (response, newValue)->
          view.trigger "group:edit:group_type", view.model, newValue