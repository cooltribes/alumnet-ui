@AlumNet.module 'AdminApp.EmailsNew', (EmailsNew, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsNew.Layout extends Marionette.LayoutView
    template: 'admin/emails/new/templates/layout'
    className: 'container'

    regions:
      groups_users: "#groups_users"

    initialize: ->
      AlumNet.setTitle('Send Campaign')

  class EmailsNew.User extends Marionette.ItemView
    template: 'admin/emails/new/templates/_user'

    ui:
      'select_user': '#js-select-user'
      'deselect_user': '#js-deselect-user'
    events:
      'click @ui.select_user': 'selectUser'
      'click @ui.deselect_user': 'deselectUser'

    selectUser: -> 
      #$("#js-select-user").removeClass("emails__user").addClass("emails__user--active")
      #$("#js-select-user").attr("id","js-deselect-user")

    deselectUser: ->
      #$("#js-deselect-user").removeClass("emails__user--active").addClass("emails__user")
      #$("#js-deselect-user").attr("id","js-select-user")

  class EmailsNew.AddFilter extends Marionette.LayoutView
    template: 'admin/emails/new/templates/_add_filter'

  class EmailsNew.Users extends Marionette.ItemView
    template: 'admin/emails/new/templates/users'

  class EmailsNew.GroupsUsers extends Marionette.CompositeView
    template: 'admin/emails/new/templates/groups_users'
    childViewContainer: '#list-users'
    childView: EmailsNew.User

    ui:
      'selectGroups': '.js-select-groups'
      'mailchimpDetails': '#js-mailchimp-account-details'
      'mailchimpAssociate': '#js-mailchimp-associate'
      'apiKey': '#js-api-key'
      'listId': '#js-list-id'
      'submit': '#js-submit'
      'emailSubject': '#subject'
      'emailBody': '#email-body'

    events:
      'click #js-remove-associated-span': 'removeAsocciatedMailChimp'
      'click #js-add-filter': 'addFilter'
      'change @ui.selectGroups': 'changeSelectGroups'
      'click @ui.submit': 'sendCampaign'
      'click a#js-edit-api-key': 'toggleEditApiKey'
      'click a#js-edit-list-id': 'toggleEditListId'
      'click #js-validate-mailchimp': 'validateMailchimp'
      'click a#js-migrate-users': 'migrateUsers'
      'click #js-mailchimp-associate': 'mailchimpAssociateClicked'
      'click #send-campaign-to-me': 'sendToMe'
      'click #show-campaign-preview': 'showPreview'

    initialize: (options)->
      @groups = options.groups
      @current_user = options.current_user

    templateHelpers: ->
      groups: @groups.models
      currentUserIsAdmin: @current_user.isAlumnetAdmin()

    changeSelectGroups: ->
      view = @
      if @ui.selectGroups.val() != "-1"
        group = @groups.get(@ui.selectGroups.val())
        members = group.get('members')
        view.collection.set members

        @ui.apiKey.editable
          type: 'text'
          value: group.get('api_key')
          pk: group.id
          title: 'API Key'
          toggle: 'manual'
          success: (response, newValue)->
            view.trigger 'group:edit:api_key', group, newValue

        @ui.listId.editable
          type: 'text'
          value: group.get('list_id')
          pk: group.id
          title: 'List ID'
          toggle: 'manual'
          success: (response, newValue)->
            view.trigger 'group:edit:list_id', group, newValue

        if group.get('mailchimp')
          @ui.apiKey.html(group.get('api_key'))
          @ui.listId.html(group.get('list_id'))

          @ui.mailchimpDetails.show()
          @ui.mailchimpAssociate.hide()
        else
          @ui.apiKey.html('')
          @ui.listId.html('')

          @ui.mailchimpAssociate.show()
          @ui.mailchimpDetails.hide()
      else
        @ui.mailchimpDetails.hide()
        @ui.mailchimpAssociate.hide()
        view.collection.set []
      
    sendCampaign: (e)->
      e.preventDefault()
      valid = true
      view = @

      if @ui.selectGroups.val() == "-1"
        valid = false
        $.growl.error({ message: 'Please select a group' })

      if @ui.emailSubject.val() == ""
        valid = false
        $.growl.error({ message: 'Please insert campaign subject' })

      if @ui.emailBody.val() == ""
        valid = false
        $.growl.error({ message: 'Please add campaign content' })

      if valid
        resp = confirm('You are about to send a campaign to selected users. Are you sure it\'s done?')
        if resp
          data = Backbone.Syphon.serialize(this)
          #data.body = $('#email-body').code().replace(/<\/?[^>]+(>|$)/g, "")
          data.body = $('#email-body').summernote('code')
          data.user_id = AlumNet.current_user.id
          if view.provider_id
            data.provider_id = view.provider_id

          group_id = data.group_id
          url = AlumNet.api_endpoint + "/groups/#{group_id}/campaigns"

          Backbone.ajax
            url: url
            type: "POST"
            data: data
            success: (data) =>
              AlumNet.trigger "campaign:sent", group_id, data.id
            error: (response) =>
              $.growl.error({ message: 'Error sending campaign' })

    sendToMe: (e)->
      e.preventDefault()
      valid = true
      view = @

      if @ui.selectGroups.val() == "-1"
        valid = false
        $.growl.error({ message: 'Please select a group' })

      if @ui.emailSubject.val() == ""
        valid = false
        $.growl.error({ message: 'Please insert campaign subject' })

      if @ui.emailBody.val() == ""
        valid = false
        $.growl.error({ message: 'Please add campaign content' })

      if valid
        resp = confirm('You are about to send a campaign to selected users. Are you sure it\'s done?')
        if resp
          data = Backbone.Syphon.serialize(this)
          data.body = $('#email-body').summernote('code')
          data.user_id = AlumNet.current_user.id
          if view.provider_id
            data.provider_id = view.provider_id

          group_id = data.group_id
          url = AlumNet.api_endpoint + "/groups/#{group_id}/campaigns/send_test"

          Backbone.ajax
            url: url
            type: "POST"
            data: data
            success: (data) =>
              view.provider_id = data.provider_id
              $.growl.notice({ message: 'Campaing preview sent' })
            error: (response) =>
              $.growl.error({ message: 'Error sending preview' })

    showPreview: (e)->
      e.preventDefault()
      valid = true
      view = @

      if @ui.selectGroups.val() == "-1"
        valid = false
        $.growl.error({ message: 'Please select a group' })

      if @ui.emailSubject.val() == ""
        valid = false
        $.growl.error({ message: 'Please insert campaign subject' })

      if @ui.emailBody.val() == ""
        valid = false
        $.growl.error({ message: 'Please add campaign content' })

      if valid
        data = Backbone.Syphon.serialize(this)
        data.body = $('#email-body').summernote('code')
        data.user_id = AlumNet.current_user.id
        if view.provider_id
          data.provider_id = view.provider_id

        group_id = data.group_id
        url = AlumNet.api_endpoint + "/groups/#{group_id}/campaigns/preview"

        Backbone.ajax
          url: url
          type: "POST"
          data: data
          success: (data) =>
            modal = new EmailsNew.Preview
              data: data
            $('#container-modal-preview').html(modal.render().el)
          error: (response) =>
            $.growl.error({ message: 'Error getting preview' })

    addFilter: (e)->
      #console.log "PRESIONO AGREGAR FILTRO"

    toggleEditApiKey: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.apiKey.editable('toggle')

    toggleEditListId: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.listId.editable('toggle')

    validateMailchimp:(e)->
      e.preventDefault()
      resp = confirm('API Key and List ID must exist and be valid, do you want to continue?')
      if resp
        data = Backbone.Syphon.serialize(this)
        id = data.group_id
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

    migrateUsers:(e)->
      e.preventDefault()
      resp = confirm('API Key and List ID must exist and be valid, do you want to continue?')
      if resp
        $(".loadingAnimation__migrateUsers").css('display','inline-block')
        data = Backbone.Syphon.serialize(this)
        id = data.group_id
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

    mailchimpAssociateClicked:(e)->
      e.preventDefault()
      @ui.mailchimpDetails.show()
      @ui.mailchimpAssociate.hide()

    onShow: ->
      summernote_options_description =
        height: 200
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']]
          ['para', ['ul', 'ol']]
        ]

      $('#email-body').summernote(summernote_options_description)

  class EmailsNew.Preview extends Backbone.Modal
    template: 'admin/emails/new/templates/preview'
    cancelEl: '#js-close'

    initialize: (options) ->
      @html = options.data.html

    onShow: ->
      $('#preview-body').html(@html)