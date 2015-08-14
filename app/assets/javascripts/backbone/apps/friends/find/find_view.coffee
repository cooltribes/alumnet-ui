@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.EmptyView extends Marionette.ItemView
    template: 'friends/find/templates/empty'

  class Find.UserView extends AlumNet.Shared.Views.UserView
    template: 'friends/find/templates/user'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'

  class Find.UsersView extends Marionette.CompositeView
    template: 'friends/find/templates/users_container'
    childView: Find.UserView
    emptyView: Find.EmptyView
    childViewContainer: '.users-list'
    events:
      'click .js-search': 'performSearch'

    initialize: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreUsers')
      $(window).scroll(@loadMoreUsers)

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
      )('//api.cloudsponge.com/widget/2b05ca85510fb736f4dac18a06b9b6a28004f5fa.js')
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
