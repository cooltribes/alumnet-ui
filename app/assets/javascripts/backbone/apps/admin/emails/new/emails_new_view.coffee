@AlumNet.module 'AdminApp.EmailsNew', (EmailsNew, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsNew.Layout extends Marionette.LayoutView
    template: 'admin/emails/new/templates/layout'
    className: 'container'

    regions:
      groups_users: "#groups_users"

    initialize: ->
      document.title = 'AlumNet - Send Campaign'

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

    events:
      'click #js-remove-associated-span': 'removeAsocciatedMailChimp'
      'click #js-add-filter': 'addFilter'
      'change @ui.selectGroups': 'changeSelectGroups'
      'click @ui.submit': 'sendCampaign'
      'click a#js-edit-api-key': 'toggleEditApiKey'

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
        console.log 'got group'
        console.log group
        members = group.get('members')
        view.collection.set members

        if group.get('mailchimp')
          @ui.apiKey.html(group.get('api_key'))
          @ui.listId.html(group.get('list_id'))

          @ui.apiKey.editable
            type: 'text'
            value: group.get('api_key')
            pk: group.id
            title: 'API Key'
            toggle: 'manual'
            success: (response, newValue)->
              view.trigger 'group:edit:api_key', group, newValue

          console.log 'editable added'

          @ui.mailchimpDetails.show()
          @ui.mailchimpAssociate.hide()
        else
          @ui.mailchimpAssociate.show()
          @ui.mailchimpDetails.hide()
      else
        @ui.mailchimpDetails.hide()
        @ui.mailchimpAssociate.hide()
        view.collection.set []
      
    sendCampaign: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      #data.body = $('#email-body').code().replace(/<\/?[^>]+(>|$)/g, "")
      data.body = $('#email-body').code()
      data.user_id = AlumNet.current_user.id
      console.log data

      group_id = data.group_id
      url = AlumNet.api_endpoint + "/groups/#{group_id}/campaigns"

      Backbone.ajax
        url: url
        type: "POST"
        data: data
        success: (data) =>
          console.log 'success'
          console.log data
          AlumNet.trigger "campaign:sent", group_id, data.id
        error: (response) =>
          console.log 'error'
          console.log response

    removeAsocciatedMailChimp: (e)->
      console.log 'remove'

    addFilter: (e)->
      console.log "PRESIONO AGREGAR FILTRO"

    toggleEditApiKey: (e)->
      e.stopPropagation()
      e.preventDefault()
      console.log 'toggle edit api key'
      @ui.apiKey.editable('toggle')

    onShow: ->
      summernote_options_description =
        height: 200
        toolbar: [
          ['style', ['bold', 'italic', 'underline', 'clear']]
          ['para', ['ul', 'ol']]
        ]

      $('#email-body').summernote(summernote_options_description)