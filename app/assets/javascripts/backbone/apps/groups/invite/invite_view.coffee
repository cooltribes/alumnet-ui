@AlumNet.module 'GroupsApp.Invite', (Invite, @AlumNet, Backbone, Marionette, $, _) ->

  class Invite.User extends Marionette.ItemView
    template: 'groups/invite/templates/user'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'
    initialize: (options) ->
      @parentModel = options.parentModel

    templateHelpers: ->
      membership_users = @parentModel.get('membership_users')
      wasInvited: ->
        user_id = this.id
        _.contains(membership_users, user_id)

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
    childViewOptions: ->
      parentModel: this.model

    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      this.trigger('users:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm
