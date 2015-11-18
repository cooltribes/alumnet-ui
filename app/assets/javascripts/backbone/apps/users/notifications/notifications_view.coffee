@AlumNet.module 'UsersApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
  class Notifications.Layout extends Marionette.LayoutView
    template: 'users/notifications/templates/notifications_management'
    className: 'container'

    regions:
      messages_members: "#messages_members"
      messages_alumnet: "#messages_alumnet"
      events_digest: "#events_digest"
      groups_digest: "#groups_digest"
      notifications: "#notifications"
      update: "#update"

    events:
      'click .smoothClick':'smoothClick'

    initialize: ->
      $(window).on 'scroll' , =>
        if $('body').scrollTop()>500
          $('#notificationsAffix').css
            'position': 'fixed'
            'width' : '213px'
            'top' : '120px'
        else
          if $('html').scrollTop()>500
            $('#notificationsAffix').css
              'position': 'fixed'
              'width' : '213px'
              'top' : '120px'
          else
            $('#notificationsAffix').css
              'position': 'relative'
              'top':'0px'
              'width':'100%'

    smoothClick: (e)->

      if $(e.target).prop("tagName")!='a'
        element = $(e.target).closest 'a'
      else
        element = e.target
        
      String id = $(element).attr("id")
      id = '#'+id.replace('to','')
      $('html,body').animate({
        scrollTop: $(id).offset().top-120
      }, 1000);

  class Notifications.Preference extends Marionette.ItemView
    #className: 'col-md-4'
    template: 'users/notifications/templates/_preference'

    # modelEvents:
    #   "change": "modelChange"

    bindings:
      "[name=approval]": 
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "Individual email"
          ,
            value: 1
            label: "No Email"
          ,
          ]
      "[name=friendship]": 
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "Individual email"
          ,
            value: 1
            label: "No Email"
          ,
          ]
      "[name=join_group_invitation]": 
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "Individual email"
          ,
            value: 1
            label: "No Email"
          ,
          ]
      "[name=message]": 
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "Individual email"
          ,
            value: 1
            label: "No Email"
          ,
          ]
      "[name=join_event]": 
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "Individual email"
          ,
            value: 1
            label: "No Email"
          ,
          ]
      "[name=join_group_request]": 
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "Individual email"
          ,
            value: 1
            label: "No Email"
          ,
          ]

    templateHelpers: ->
      model = @model
      getTitle: ->
        switch model.get('name')
          when 'approval' then 'Approval requests'
          when 'friendship' then 'Friendship invitations'
          when 'join_group_invitation' then 'Join group invitations'
          when 'message' then 'Messages'
          when 'join_event' then 'Event invitations'
          when 'join_group_request' then 'Join your group requests'

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()
      

  class Notifications.MessagesMembers extends Marionette.CompositeView
    template: 'users/notifications/templates/messages_members'
    childView: Notifications.Preference
    childViewContainer: '.js-list'
    className: 'container-fluid'

    ui:
      'submitLink': '.js-submit'
      'cancelLink': '.js-cancel'
      'invitations_to_join_groups': '#invitations_to_join_groups'

    events:
      'click @ui.submitLink': 'submitClicked'
      'click @ui.cancelLink': 'cancelClicked'

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      success = true
      _.each data, (value, key, list)->
        preference = new AlumNet.Entities.EmailPreference
          name: key
          value: value
          user_id: AlumNet.current_user.id

        if not preference.save null
          success = false

      if success
        $.growl.notice({ message: 'Preferences saved successfully' })
      else
        $.growl.error({ message: 'Error saving preferences. Please try again or contact an admin.' })

    cancelClicked: (e)->
      e.preventDefault()

  class Notifications.messagesAlumnet extends Marionette.CompositeView
    template: 'users/notifications/templates/messages_alumnet'

  class Notifications.eventsDigest extends Marionette.CompositeView
    template: 'users/notifications/templates/events_digest'

  class Notifications.groupsDigest extends Marionette.CompositeView
    template: 'users/notifications/templates/groups_digest'

  class Notifications.notificationsView extends Marionette.CompositeView
    template: 'users/notifications/templates/notifications'

  class Notifications.update extends Marionette.CompositeView
    template: 'users/notifications/templates/update'

