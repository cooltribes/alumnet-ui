@AlumNet.module 'UsersApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
  class Notifications.Layout extends Marionette.LayoutView
    template: 'users/settings/templates/notifications_management'
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
    template: 'users/settings/templates/_preference'

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
      "[name=friendship_accepted]": 
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
      "[name=apply_job_post]": 
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
      "[name=commented_post_edit]": 
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
      "[name=commented_or_liked_post_comment]": 
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
          when 'friendship_accepted' then 'User accepts friendship invitation'
          when 'join_group_invitation' then 'Join group invitations'
          when 'message' then 'Messages'
          when 'join_event' then 'Event invitations'
          when 'join_group_request' then 'Join your group requests'
          when 'apply_job_post' then 'Applies to your Job Post'
          when 'commented_post_edit' then 'User edits post you have commented'
          when 'commented_or_liked_post_comment' then 'User comments post you have commented or liked'

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()
      
  class Notifications.GroupPreference extends Marionette.ItemView
    #className: 'col-md-4'
    template: 'users/settings/templates/_group_preference'

    bindings:
      ".js-group":
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "No Email"
          ,
            value: 1
            label: "Daily"
          ,
            value: 2
            label: "Weekly"
          ,
            value: 3
            label: "Monthly"
          ,
          ]

    templateHelpers: ->
      model = @model
      getTitle: ->
        model.get('group_name')

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

  class Notifications.MessagesView extends Marionette.CompositeView
    template: 'users/settings/templates/messages_members'
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
    template: 'users/settings/templates/messages_alumnet'

  class Notifications.eventsDigest extends Marionette.CompositeView
    template: 'users/settings/templates/events_digest'

  class Notifications.GroupsView extends Marionette.CompositeView
    template: 'users/settings/templates/groups_digest'
    childView: Notifications.GroupPreference
    childViewContainer: '.js-list'
    className: 'container-fluid'

    ui:
      'submitLink': '.js-submit'
      'cancelLink': '.js-cancel'

    events:
      'click @ui.submitLink': 'submitClicked'
      'click @ui.cancelLink': 'cancelClicked'

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      success = true
      _.each data, (value, key, list)->
        preference = new AlumNet.Entities.GroupEmailPreference
          group_id: key
          value: value[0]
          user_id: AlumNet.current_user.id

        if not preference.save null
          success = false

      if success
        $.growl.notice({ message: 'Preferences saved successfully' })
      else
        $.growl.error({ message: 'Error saving preferences. Please try again or contact an admin.' })

    cancelClicked: (e)->
      e.preventDefault()

  class Notifications.NewsView extends Marionette.CompositeView
    template: 'users/settings/templates/notifications'
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

  class Notifications.update extends Marionette.CompositeView
    template: 'users/settings/templates/update'

