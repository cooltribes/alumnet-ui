@AlumNet.module 'GroupsApp.Members', (Members, @AlumNet, Backbone, Marionette, $, _) ->
  class Members.Modal extends Backbone.Modal
    template: 'groups/members/templates/modal'
    cancelEl: '.js-modal-close'
    events:
      'click .js-modal-save': 'saveClicked'

    saveClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      modal = @
      @model.set(data)
      @model.save {},
        success: ->
          modal.destroy()

  class Members.MembersLayout extends Marionette.LayoutView
    template: 'groups/members/templates/layout'
    regions:
      requests: '#js-requests-container'
      alumni: '#js-alumni-container'

  class Members.Request extends Marionette.ItemView
    template: 'groups/members/templates/request'
    ui:
      'acceptMembershipLink': '#js-accept-membership'
      'deleteMembershipLink': '#js-delete-membership'
    events:
      'click @ui.acceptMembershipLink': 'acceptClicked'
      'click @ui.deleteMembershipLink': 'deleteClicked'

    acceptClicked: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'membership:accepted'


    deleteClicked: (e)->
      e.preventDefault()
      e.stopPropagation()
      @model.destroy()

  class Members.RequestsView extends Marionette.CompositeView
    template: 'groups/members/templates/requests_container'
    childView: Members.Request
    childViewContainer: '.requests-list'
    ui:
      'resquestsCount': '#js-requests-count'

    initialize: ->
      self = @
      @collection.on 'fetch:success', (collection)->
        self.updateRequestsCount(collection)
      @collection.on 'destroy remove', ->
        self.updateRequestsCount(self.collection)

    updateRequestsCount: (collection)->
      count = collection.length
      @ui.resquestsCount.html(count)

  class Members.Member extends Marionette.ItemView
    template: 'groups/members/templates/member'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'

    initialize: (options)->
      @group = options.group

    templateHelpers: ->
      userCanMakeAdmin: @group.canDo('make_admin')
      userIsNotCurrentUser: not @memberIsCurrentUser()

    memberIsCurrentUser: ->
      user = @model.get 'user'
      current_user = AlumNet.current_user
      user.id == current_user.id

    ui:
      'removeMemberLink': '.js-remove-member'
      'changeTypeLink': '.js-change-type'

    events:
      'click @ui.removeMemberLink': 'removeClicked'
      'click @ui.changeTypeLink': 'changeClicked'

    removeClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      resp = confirm('Are you sure?')
      if resp
        membership = AlumNet.request("membership:destroy", @model)

    changeClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      modal = new Members.Modal
        model: @model
      $('.js-modal-container').html(modal.render().el)

  class Members.MembersView extends Marionette.CompositeView
    template: 'groups/members/templates/members_container'
    childView: Members.Member
    className: 'container-fluid'
    childViewContainer: '.members-list'

    childViewOptions: ->
      group: @model

    initialize: ->
      self = @
      @collection.on 'fetch:success', (collection)->
        self.updateMembersCounts(collection)
      @collection.on 'destroy remove add', ->
        self.updateMembersCounts(self.collection)

    ui:
      'membersCount': '#js-members-count'
      'friendsCount': '#js-friends-count'

    events:
      'click .js-search': 'performSearch'
      'click #js-members-count': 'allMembers'
      'click #js-friends-count': 'filterFriends'

    filterFriends: (e)->
      e.preventDefault()
      e.stopPropagation()
      @collection.reset(@friends)

    allMembers: (e)->
      e.preventDefault()
      e.stopPropagation()
      @collection.reset(@members)
      # @collection.fetch()

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

    updateMembersCounts: (collection)->
      @friends = collection.where({is_friend: true})
      @members = collection.slice()
      @ui.membersCount.html("All members(#{collection.length})")
      @ui.friendsCount.html("Friends(#{@friends.length})")
