@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Layout extends Marionette.LayoutView
    template: 'admin/users/show/templates/layout'
    #className: 'container'
      
    regions:
      'content': '#js-content'
    ui:
      'overviewLink': '#js-section-overview'
      'personalLink': '#js-section-personal'
      'contactsLink': '#js-section-contacts'
      'professionalLink': '#js-section-professional'
      'groupsLink': '#js-section-groups'
      'eventsLink': '#js-section-events'
      'purchasesLink': '#js-section-purchases'
      'pointsLink': '#js-section-points'
      'adminLink': '#js-section-admin'

    events:
      'click @ui.overviewLink': 'overviewClicked'
      'click @ui.personalLink': 'personalClicked'
      'click @ui.contactsLink': 'contactsClicked'
      'click @ui.professionalLink': 'professionalClicked'
      'click @ui.groupsLink': 'groupsClicked'
      'click @ui.eventsLink': 'eventsClicked'
      'click @ui.purchasesLink': 'purchasesClicked'
      'click @ui.pointsLink': 'pointsClicked'
      'click @ui.adminLink': 'adminClicked'

    overviewClicked: (e)->
      e.preventDefault()
      overview = new UserShow.Overview
        model: @model
      @content.show(overview)

    personalClicked: (e)->
      e.preventDefault()
      personal = new UserShow.Personal
        model: @model
      @content.show(personal)

    contactsClicked: (e)->
      e.preventDefault()
      view = @
      contacts = new AlumNet.Entities.ProfileContactsCollection
      contacts.url = AlumNet.api_endpoint + "/profiles/#{@model.get('profile_id')}/contact_infos"
      contacts.fetch
        success: ->
          contactsView = new UserShow.Contacts
            model: view.model
            collection: contacts
          view.content.show(contactsView)

    professionalClicked: (e)->
      e.preventDefault()
      view = @
      experiences = new AlumNet.Entities.ExperienceCollection
      experiences.url = AlumNet.api_endpoint + "/profiles/#{@model.get('profile_id')}/experiences"
      experiences.fetch
        data:
          q: { exp_type_eq: 3 }
        success: ->
          experiencesView = new UserShow.Experiences
            model: view.model
            collection: experiences
          view.content.show(experiencesView)

    groupsClicked: (e)->
      e.preventDefault()
      view = @
      groups = new AlumNet.Entities.GroupCollection
      groups.url = AlumNet.api_endpoint + "/admin/users/#{@model.id}/groups"
      groups.fetch
        success: ->
          groupsView = new UserShow.Groups
            model: view.model
            collection: groups
          view.content.show(groupsView)

    eventsClicked: (e)->
      e.preventDefault()
      view = @
      events = new AlumNet.Entities.EventsCollection
      events.url = AlumNet.api_endpoint + "/admin/users/#{@model.id}/events"
      events.fetch
        success: ->
          eventsView = new UserShow.Events
            model: view.model
            collection: events
          view.content.show(eventsView)

    adminClicked: (e)->
      e.preventDefault()
      admin = new UserShow.Admin
        model: @model
      @content.show(admin)

  class UserShow.Overview extends Marionette.LayoutView
    template: 'admin/users/show/templates/overview'
    regions:
      'contacts': '#js-overview-contacts'
      'experiences': '#js-overview-experiences'
      'events_section': '#js-overview-events'

    templateHelpers: ->
      getCurrentLocation: @model.getCurrentLocation()
      getBornDate: @model.getBornDate()
      getAge: @model.getAge()
      showJoinGroups: @showJoinGroups()
      showManageGroups: @showManageGroups()

    showJoinGroups: ->
      return "No groups" if @model.get('join_groups').length == 0
      links = []
      _.each @model.get('join_groups'), (element)->
        links.push("<a href='#/groups/#{element.id}/about'>#{element.name}</a>")
      links.join(", ")

    showManageGroups: ->
      return "No groups" if @model.get('manage_groups').length == 0
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

      events = @model.eventsCollection()
      eventsview = new UserShow.OverviewEvents
        collection: events
        model: @model

      @contacts.show(contactsview)
      @experiences.show(experiencesview)
      @events_section.show(eventsview)

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

  class UserShow.OverviewEvent extends Marionette.ItemView
    template: 'admin/users/show/templates/_overview_event'
    templateHelpers: ->
      location: @model.getLocation()
      date: moment(@model.get('start_date')).format('DD MMM YYYY')

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

  class UserShow.OverviewEvents extends Marionette.CompositeView
    template: 'admin/users/show/templates/overview_events'
    childView: UserShow.OverviewEvent
    childViewContainer: '#js-overview-events-container'
    childViewOptions: ->
      user: @model