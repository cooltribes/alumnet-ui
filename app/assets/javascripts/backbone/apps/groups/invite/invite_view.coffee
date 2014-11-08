@AlumNet.module 'GroupsApp.Invite', (Invite, @AlumNet, Backbone, Marionette, $, _) ->

  class Invite.User extends Marionette.ItemView
    template: 'groups/invite/templates/user'
    tagName: 'li'

    templateHelpers: ->
      view = this
      wasInvited: ->
        group_id = view.parentModel.get('id')
        user_group_ids = this.groups
        _.contains(user_group_ids, group_id)

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
    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      $searchForm = this.$el.find('form#search-form')
      data = Backbone.Syphon.serialize(this)
      this.trigger('users:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        name_cont: searchTerm
        email_cont: searchTerm
