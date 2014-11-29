@AlumNet.module 'GroupsApp.Members', (Members, @AlumNet, Backbone, Marionette, $, _) ->

  class Members.Member extends Marionette.ItemView
    template: 'groups/members/templates/member'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'

  class Members.MembersView extends Marionette.CompositeView
    template: 'groups/members/templates/members_container'
    childView: Members.Member
    className: 'container-fluid'
    childViewContainer: '.members-list'
    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger('members:search', @buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        user_profile_first_name_cont: searchTerm
        user_profile_last_name_cont: searchTerm
        user_email_cont: searchTerm
