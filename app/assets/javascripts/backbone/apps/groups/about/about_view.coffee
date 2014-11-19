@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.ItemView
    template: 'groups/about/templates/about'
    templateHelpers: ->
      canEditInformation: @model.canEditInformation()
    ui:
      'groupDescription':'#description'
      'groupType': '#group_type'
    events:
      'click a#js-edit-description': 'toggleEditGroupDescription'
      'click a#js-edit-group-type': 'toggleEditGroupType'

    toggleEditGroupDescription: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupDescription.editable('toggle')

    toggleEditGroupType: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupType.editable('toggle')


    onRender: ->
      view = this
      @ui.groupDescription.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Enter the description of Group'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'group:edit:description', view.model, newValue

      @ui.groupType.editable
        type: 'select'
        value: view.model.get('group_type').value
        pk: view.model.id
        title: 'Enter the type of Group'
        toggle: 'manual'
        source: [
          {value: 0, text: 'Open'}
          {value: 1, text: 'Closed'}
        ]
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'group:edit:group_type', view.model, newValue