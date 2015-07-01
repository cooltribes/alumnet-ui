@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.ItemView
    template: 'groups/about/templates/about'

    initialize: (options)->
      @current_user = options.current_user

    templateHelpers: ->
      currentUserIsAdmin: @current_user.isAlumnetAdmin()
      canEditInformation: @model.canDo('edit_group')
      canChangeJoinProcess: @model.canDo('change_join_process')
      userHasMembership: @model.userHasMembership()
      userIsApproved:  @model.userIsMember()
      joinProcessText: @joinProcessText()
      model: @model
      mailchimp: @model.hasMailchimp()

    ui:
      'uploadFiles': '#upload'
      'groupOfficial': '#official'
      'groupDescription':'#description'
      'groupType': '#group_type'
      'joinProcess': '#join_process'
      'joinDiv': '#js-join-div'
      'groupMailchimp': '#mailchimp'
      'mailchimpContainer': '#mailchimpContainer'
      'groupApiKey': '#api_key'
      'groupListId': '#list_id'

    events:
      'click a#js-edit-upload': 'toggleEditUploadFiles'
      'click a#js-edit-official': 'toggleEditGroupOfficial'
      'click a#js-edit-description': 'toggleEditGroupDescription'
      'click a#js-edit-group-type': 'toggleEditGroupType'
      'click a#js-edit-join-process': 'toggleEditJoinProcess'
      'click .js-attribute': 'attributeClicked'
      'click .js-join':'sendJoin'
      'click a#js-delete-group': 'deleteGroup'
      'click a#js-edit-mailchimp': 'toggleEditMailchimp'
      'click a#js-edit-api-key': 'toggleEditApiKey'
      'click a#js-edit-list-id': 'toggleEditListId'
      'click a#js-migrate-users': 'migrateUsers'
      'click a#js-validate-mailchimp': 'validateMailchimp'

    deleteGroup:(e)->
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        @model.destroy
          success: ->
            AlumNet.trigger "groups:manage"

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

    migrateUsers:(e)->
      e.preventDefault()
      resp = confirm('API Key and List ID must exist and be valid, do you want to continue?')
      if resp
        $(".loadingAnimation__migrateUsers").css('display','inline-block')
        id = @model.id
        url = AlumNet.api_endpoint + "/groups/#{id}/migrate_users"
        Backbone.ajax
          url: url
          type: "GET"
          data: { id: id }
          success: (data) =>
            if(not data.success)
              $.growl.error({ message: data.message })
            else
              $(".loadingAnimation__migrateUsers").css('display','none')
              $.growl.notice({ message: "Successful migration" })
          error: (data) =>
            $.growl.error({ message: 'Unknow error, please try again' })

    validateMailchimp:(e)->
      e.preventDefault()
      resp = confirm('API Key and List ID must exist and be valid, do you want to continue?')
      if resp
        id = @model.id
        url = AlumNet.api_endpoint + "/groups/#{id}/validate_mailchimp"
        Backbone.ajax
          url: url
          type: "GET"
          data: { id: id }
          success: (data) =>
            if(data.success)
              $.growl.notice({ message: 'Valid parameters' })
            else
              $.growl.error({ message: data.message })
          error: (data) =>
            $.growl.error({ message: 'Unknow error, please try again' })

    attributeClicked: (e)->
      e.preventDefault()

    toggleEditUploadFiles: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.uploadFiles.editable('toggle')
    
    toggleEditGroupOfficial: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupOfficial.editable('toggle')

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

    toggleEditMailchimp: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupMailchimp.editable('toggle')

    toggleEditApiKey: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupApiKey.editable('toggle')

    toggleEditListId: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupListId.editable('toggle')

    editAttribute: (e)->
      $(e.target).addClass "hide"
      
    onRender: ->
      view = this
      @ui.groupDescription.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Enter the description of Group'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'Group description is required, must be less than 2048 characters'
          if $.trim(value).length >= 2048  
            'Group description is too large! Must be less than 2048 characters'                 
        success: (response, newValue)->
          view.trigger 'group:edit:description', view.model, newValue
      @ui.groupDescription.linkify()

      @ui.uploadFiles.editable
        type: 'select'
        value: view.model.get('group_type').value
        title: 'Select option'
        toggle: 'manual'
        source: [
          {value: 0, text: 'Only administrators'}
          {value: 1, text: 'All members'}          
        ]
        validate: (value)->
          if $.trim(value) == ''
            'This field is required'
        success: (response, newValue)->
          # view.trigger 'group:edit:group_type', view.model, newValue

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

      @ui.groupOfficial.editable
        type: 'select'
        value: view.model.get('official').value
        pk: view.model.id
        title: 'Select option'
        toggle: 'manual'
        source: ->
          options = []
          group = view.model
          if group.canBeUnOfficial()
            options.push {value: 0, text: "it's not an official group"}
          if group.canBeOfficial()
            options.push {value: 1, text: "it's an official group"}
          options

        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'group:edit:official', view.model, newValue
          if newValue == "0"
            view.ui.mailchimpContainer.addClass('hide')
            view.trigger 'group:edit:mailchimp', view.model, 0
          else
            view.ui.mailchimpContainer.removeClass('hide')

      @ui.groupMailchimp.editable
        type: 'select'
        value: view.model.get('mailchimp')
        pk: view.model.id
        title: 'Has mailchimp?'
        toggle: 'manual'
        source: [
          {value: 0, text: 'No'}
          {value: 1, text: 'Yes'}
        ]
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'group:edit:mailchimp', view.model, newValue

      @ui.groupApiKey.editable
        type: 'text'
        value: view.model.get('api_key')
        pk: view.model.id
        title: 'API Key'
        toggle: 'manual'
        success: (response, newValue)->
          view.trigger 'group:edit:api_key', view.model, newValue

      @ui.groupListId.editable
        type: 'text'
        value: view.model.get('list_id')
        pk: view.model.id
        title: 'List ID'
        toggle: 'manual'
        success: (response, newValue)->
          view.trigger 'group:edit:list_id', view.model, newValue