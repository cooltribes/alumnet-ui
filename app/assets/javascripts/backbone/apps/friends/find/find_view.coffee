@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.EmptyView extends Marionette.ItemView
    template: 'friends/find/templates/empty'

  class Find.UserView extends Marionette.ItemView
    template: 'friends/find/templates/user'
    tagName: 'div'
    className: 'col-md-4 col-sm-6'
    ui:
      'linkContainer': '#link-container'
      'requestLink': '#js-request-friendship'
      'acceptLink': '#js-accept-friendship'
      'rejectLink': '#js-reject-friendship'
      'cancelLink': '#js-cancel-friendship'
      'deleteLink': '#js-delete-friendship'
    events:
      'click #js-request-friendship':'clickedRequest'
      'click #js-accept-friendship':'clickedAccept'
      'click #js-reject-friendship':'clickedReject'
      'click #js-delete-friendship':'clickedDelete'
      'click #js-cancel-friendship':'clickedCancel'


    clickedAccept: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'accept'    
      @trigger 'Catch:Up'

    clickedRequest: (e)->
      e.preventDefault()
      e.stopPropagation()
      @trigger 'request'
      @trigger 'Catch:Up'

    clickedReject: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
        AlumNet.current_user.decrementCount('pending_received_friendships')

    clickedDelete: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
        AlumNet.current_user.decrementCount('friends')

    clickedCancel: (e)->
      e.preventDefault()
      e.stopPropagation()
      self = @
      attrs = @model.get('friendship')
      friendship = AlumNet.request('current_user:friendship:destroy', attrs)
      friendship.on 'delete:success', (response, options) ->
        self.removeCancelLink()
        AlumNet.current_user.decrementCount('pending_sent_friendships')

    removeCancelLink: -> 
      @model.set("friendship_status","none")
      @trigger 'Catch:Up'



  class Find.UsersView extends Marionette.CompositeView
    template: 'friends/find/templates/users_container'
    childView: Find.UserView
    emptyView: Find.EmptyView
    childViewContainer: '.users-list'
    events:
      'click .js-search': 'performSearch'

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
        profile_first_name_cont: searchTerm
        profile_last_name_cont: searchTerm
        email_cont: searchTerm
              
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
