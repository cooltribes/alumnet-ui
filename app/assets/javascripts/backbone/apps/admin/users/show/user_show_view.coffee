@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Layout extends Marionette.LayoutView
    template: 'admin/users/show/templates/layout'
    className: 'container'
    regions:
      'content': '#js-content'

  class UserShow.Overview extends Marionette.LayoutView
    template: 'admin/users/show/templates/overview'
    regions:
      'contacts': '#js-overview-contacts'
      'experiences': '#js-overview-experiences'

    templateHelpers: ->
      getCurrentLocation: @model.getCurrentLocation()
      getBornDate: @model.getBornDate()
      getAge: @model.getAge()
      showJoinGroups: @showJoinGroups()
      showManageGroups: @showManageGroups()

    showJoinGroups: ->
      return "No groups" if @model.get('join_groups').lenght == 0
      links = []
      _.each @model.get('join_groups'), (element)->
        links.push("<a href='#/groups/#{element.id}/about'>#{element.name}</a>")
      links.join(", ")

    showManageGroups: ->
      return "No groups" if @model.get('join_groups').lenght == 0
      links = []
      _.each @model.get('manage_groups'), (element)->
        links.push("<a href='#/groups/#{element.id}'>#{element.name}</a>")
      links.join(", ")

    onShow: ->
      experiences = @model.experiencesCollection()
      experiencesview = new UserShow.OverviewExperiences
        collection: experiences
        model: @model

      contacts = @model.contactsCollection()
      contactsview = new UserShow.OverviewContacts
        collection: contacts
        model: @model

      @contacts.show(contactsview)
      @experiences.show(experiencesview)

  class UserShow.OverviewContact extends Marionette.ItemView
    template: 'admin/users/show/templates/_overview_contact'
    templateHelpers: ->
      model = @model
      contactTypeText: (contact_type)->
        model.findContactType(contact_type) if model

  class UserShow.OverviewExperience extends Marionette.ItemView
    template: 'admin/users/show/templates/_overview_experience'
    templateHelpers: ->
      getStartDate: @model.getStartDate()
      getEndDate: @model.getEndDate()

  class UserShow.OverviewExperiences extends Marionette.CompositeView
    template: 'admin/users/show/templates/overview_experiences'
    childView: UserShow.OverviewExperience
    childViewContainer: '#js-overview-experiences-container'
    childViewOptions: ->
      user: @model

  class UserShow.OverviewContacts extends Marionette.CompositeView
    template: 'admin/users/show/templates/overview_contacts'
    childView: UserShow.OverviewContact
    childViewContainer: '#js-overview-contacts-container'
    childViewOptions: ->
      user: @model