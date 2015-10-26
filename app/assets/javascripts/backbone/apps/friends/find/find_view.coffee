@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.EmptyView extends Marionette.ItemView
    template: 'friends/find/templates/empty'

  class Find.UserView extends AlumNet.Shared.Views.UserView
    template: 'friends/find/templates/user'
    tagName: 'div'
    className: 'col-md-4 col-sm-6 col-xs-12'

  class Find.UsersView extends Marionette.CompositeView
    template: 'friends/find/templates/users_container'
    childView: Find.UserView
    emptyView: Find.EmptyView
    #childViewOptions: ->
    #  parentCollection: @collection
    childViewContainer: '.users-list'
    events:
      'click .js-simple-search': 'performSearch'
      'click .add-new-filter': 'addNewFilter'
      'click .search': 'advancedSearch'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'
      'click #js-advance':'showBoxAdvanceSearch'
      'click #js-basic' : 'showBoxAdvanceBasic'

    ui:
      'loading': '.throbber-loader'
      
    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreUsers')      
      $(window).scroll(@loadMoreUsers)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMoreUsers: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'user:reload'

    onShow: ->
      view = @
      ((url)->
        script = document.createElement('script')
        m = document.getElementsByTagName('script')[0]
        script.async = 1
        script.src = url
        m.parentNode.insertBefore(script, m)
      )('//api.cloudsponge.com/widget/df94a984c578bbfb7ec51eeca8557d2801d944b5.js')
      window.csPageOptions =
        skipSourceMenu: true
        initiallySelectedContacts: true
        afterInit: ->
          links = document.getElementsByClassName('delayed');
          for link in links
            link.href = '#'
        beforeDisplayContacts: (contacts, source, owner)->
          view.formatContact(contacts)
          false
      # Advanced search
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "profile_first_name_or_profile_last_name", type: "string", values: "" },
        { attribute: "profile_residence_country_name", type: "string", values: "" },
        { attribute: "profile_birth_country_name", type: "string", values: "" }
        { attribute: "profile_residence_city_name", type: "string", values: "" }
        { attribute: "profile_birth_city_name", type: "string", values: "" }
        { attribute: "profile_experiences_committee_name", type: "string", values: "" }
        { attribute: "profile_experiences_organization_name", type: "string", values: "" }
      ])

    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    advancedSearch: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @collection.fetch
        data: { q: query }

    clear: (e)->
      e.preventDefault()
      @collection.fetch()

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (model)->
          view.render()

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', @buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        profile_first_name_cont_any: searchTerm.split(" ")
        profile_last_name_cont_any: searchTerm.split(" ")
        profile_residence_city_name_cont_any: searchTerm
        email_cont_any: searchTerm

    formatContact: (contacts)->
      view = @
      formatedContacts = []
      _.map contacts, (contact)->
        formatedContacts.push({name: contact.fullName(), email: contact.selectedEmail()})
      users = new AlumNet.Entities.ContactsInAlumnet
      users.fetch
        method: 'POST'
        data: { contacts: formatedContacts }
        success: (collection)->
          view.collection.set(collection.models)

    showBoxAdvanceSearch: (e)->
      e.preventDefault()
      $("#js-advance-search").slideToggle("slow")
      $("#search-form").slideToggle("hide");

    showBoxAdvanceBasic: (e)->
      e.preventDefault()
      $("#search-form").slideToggle("slow");
      $("#js-advance-search").slideToggle("hide")
