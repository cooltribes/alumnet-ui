@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.ItemView
    template: 'groups/about/templates/about'

    templateHelpers: ->
      canEditInformation: @model.canDo('edit_group')
      canChangeJoinProcess: @model.canDo('change_join_process')
      userHasMembership: @model.userHasMembership()
      userIsApproved:  @model.userIsMember()
      joinProcessText: @joinProcessText()

    ui:
      'groupDescription':'#description'
      'groupType': '#group_type'
      'joinProcess': '#join_process'
      'joinDiv': '#js-join-div'

    events:
      'click a#js-edit-description': 'toggleEditGroupDescription'
      'click a#js-edit-group-type': 'toggleEditGroupType'
      'click a#js-edit-join-process': 'toggleEditJoinProcess'
      'click .js-attribute': 'attributeClicked'
      'click .js-join':'sendJoin'

    sendJoin:(e)->
      e.preventDefault()
      @trigger 'join'

    joinProcessOptions: =>
      value = @model.get('group_type').value
      if value == 1
        [ {value: 1, text: 'All Members can invite, but the admins approved'}
          {value: 2, text: 'Only the admins can invite'}]
      else if value == 2
        [ {value: 2, text: 'Only the admins can invite'}]
      else
        [ {value: 0, text: 'All Members can invite'}
          {value: 1, text: 'All Members can invite, but the admins approved'}
          {value: 2, text: 'Only the admins can invite'}]

    joinProcessText: ->
      switch @model.get 'join_process'
        when 0
          "All Members can invite"
        when 1
          "All Members can invite, but the admins approved"
        when 2
          "Only the admins can invite"
        else
          ""
    attributeClicked: (e)->
      e.preventDefault()

    toggleEditGroupDescription: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupDescription.editable('toggle')

    toggleEditGroupType: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupType.editable('toggle')

    toggleEditJoinProcess: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.joinProcess.editable('toggle')


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
          {value: 2, text: 'Secret'}
        ]
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'group:edit:group_type', view.model, newValue

      @ui.joinProcess.editable
        type: 'select'
        value: view.model.get('join_process')
        pk: view.model.id
        title: 'Enter the join process'
        toggle: 'manual'
        source: ->
          view.joinProcessOptions()
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'group:edit:join_process', view.model, newValue