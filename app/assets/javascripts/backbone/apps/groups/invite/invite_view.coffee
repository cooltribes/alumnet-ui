@AlumNet.module 'GroupsApp.Invite', (Invite, @AlumNet, Backbone, Marionette, $, _) ->

  class Invite.User extends Marionette.ItemView
    template: 'groups/invite/templates/user'
    tagName: 'li'
    ui:
      invitation: ".invitation"
      inviteLink: "a.js-invite"
    events:
      'click a.js-invite':'clickInvite'
    clickInvite: (e)->
      e.preventDefault()
      @trigger 'invite'

    removeLink: ->
      @ui.inviteLink.remove()
      @ui.invitation.append('<span>Invited</span>')

  class Invite.Users extends Marionette.CompositeView
    template: 'groups/invite/templates/users_container'
    childView: Invite.User
    childViewContainer: ".users-list"