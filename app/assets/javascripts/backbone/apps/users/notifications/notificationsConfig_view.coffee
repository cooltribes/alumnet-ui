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


  class Notifications.messagesMembers extends Marionette.CompositeView
    template: 'users/notifications/templates/messages_members'

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

