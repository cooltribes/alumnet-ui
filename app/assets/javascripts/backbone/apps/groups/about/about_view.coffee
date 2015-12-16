@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.ItemView
    template: 'groups/about/templates/about'

    getTemplate: ->
      if not @model.userHasMembership() && not @model.userIsMember()
        'groups/about/templates/about_group_closed'
      else
        'groups/about/templates/about'

    initialize: (options)->
      @current_user = options.current_user

    templateHelpers: ->
      model = @model
      other_members: @other_members()
      currentUserIsAdmin: @current_user.isAlumnetAdmin()
      canEditInformation: @model.canDo('edit_group')
      canChangeJoinProcess: @model.canDo('change_join_process')
      userHasMembership: @model.userHasMembership()
      userIsApproved:  @model.userIsMember()
      joinProcessText: @joinProcessText()
      model: @model
      mailchimp: @model.hasMailchimp()
      uploadFilesText: @model.uploadFilesText(true)
      otherMembers: @totalMembers()

    ui:
      'uploadFiles': '#upload-files'
      'groupOfficial': '#official'
      'groupDescription':'#description'
      'groupType': '#group_type'
      'joinProcess': '#join_process'
      'joinDiv': '#js-join-div'
      'groupMailchimp': '#mailchimp'
      'mailchimpContainer': '#mailchimpContainer'
      'groupApiKey': '#api_key'
      'groupListId': '#list_id'
      'linkSaveDescription': 'a#js-save-description'
      'shortDescription': 'a#short-description'

    events:
      'click a#js-edit-upload': 'toggleEditUploadFiles'
      'click a#js-edit-official': 'toggleEditGroupOfficial'
      'click a#js-edit-description': 'toggleEditGroupDescription'
      'click a#js-edit-group-type': 'toggleEditGroupType'
      'click a#js-edit-join-process': 'toggleEditJoinProcess'
      'click .js-join':'sendJoin'
      'click a#js-delete-group': 'deleteGroup'
      'click a#js-edit-mailchimp': 'toggleEditMailchimp'
      'click a#js-edit-api-key': 'toggleEditApiKey'
      'click a#js-edit-list-id': 'toggleEditListId'
      'click a#js-migrate-users': 'migrateUsers'
      'click @ui.linkSaveDescription': 'saveDescription'

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

    toggleEditUploadFiles: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.uploadFiles.editable('toggle')

    toggleEditGroupOfficial: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.groupOfficial.editable('toggle')

    toggleEditGroupDescription: (e)->
      e.preventDefault()
      link = $(e.currentTarget)
      if link.html() == '[edit]'
        @ui.groupDescription.summernote({height: 100})
        link.html('[close]')
        @ui.linkSaveDescription.show()
      else
        @ui.groupDescription.destroy()
        link.html('[edit]')
        @ui.linkSaveDescription.hide()

    saveDescription: (e)->
      e.preventDefault()
      value = @ui.groupDescription.code()
      unless value.replace(/<\/?[^>]+(>|$)/g, "").replace(/\s|&nbsp;/g, "") == ""
        @trigger 'group:edit:description', @model, value
        @ui.groupDescription.destroy()
        $('a#js-edit-description').html('[edit]')
        $(e.currentTarget).hide()

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

    toggleEditUploadFiles: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.uploadFiles.editable('toggle')

    editAttribute: (e)->
      $(e.target).addClass "hide"

    totalMembers: ->
      otherMembers = (@model.get("members").length - @model.get("friends_in").length) - @model.get("admins").length
      if otherMembers < 0
        otherMembers = 0
      else
        otherMembers

    other_members: ->
      members = []
      arrayFriendsAdmins = _.union(@model.get('admins'),@model.get('friends_in'))
      for member in @model.get("members")
        exist = false
        for friendAdmins in arrayFriendsAdmins
          if member.id == friendAdmins.id
            exist = true
        unless exist
          members.push member
      members

    onRender: ->
      view = this

      @ui.uploadFiles.editable
        type:'select'
        value: view.model.get('upload_files')
        source: view.model.uploadFilesText()
        toggle: 'manual'
        success: (response, newValue)->
          view.model.save
            "upload_files": newValue

      @ui.shortDescription.editable
        type: 'text'
        pk: view.model.id
        title: 'Enter the Short description of Group'
        emptytext: "Short description"
        success: (response, newValue)->
          view.model.save { short_description: newValue }

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