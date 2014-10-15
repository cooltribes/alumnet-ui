@AlumNet.module 'GroupsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->

  class Create.GroupForm extends Marionette.ItemView
    template: 'groups/create/templates/form'

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr) ->
        invalid: (view, attr, error) ->
          alert "#{attr}: #{error}"

    events:
      "click button.js-submit":"submitClicked"
    submitClicked: (e)->
      e.preventDefault()
      this.trigger("form:submit", this)
