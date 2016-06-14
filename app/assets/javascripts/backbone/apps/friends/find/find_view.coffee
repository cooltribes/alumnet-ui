@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.EmptyView extends Marionette.ItemView
    template: 'friends/find/templates/empty'
    initialize: (options)->
      @search_term = options.search_term

    templateHelpers: ->
      search_term: @search_term


  class Find.UserView extends AlumNet.Shared.Views.UserView
    template: 'friends/find/templates/user'
    tagName: 'div'
    className: 'col-md-6 col-sm-6 col-xs-12'

    templateHelpers: ->
      model = @model
      position: ->
        if model.get("professional_headline")
          model.get("professional_headline")
        else if model.get("last_experience")
          model.get("last_experience")
        else
          "No Position"

  class Find.UsersView extends Marionette.CompositeView
    template: 'friends/find/templates/users_container'
    childView: Find.UserView
    emptyView: Find.EmptyView
    childViewContainer: '.users-list'

    emptyViewOptions: ->
      search_term: @search_term

    initialize: (options)->
      @parentView = options.parentView

    ui:
      'loading': '.throbber-loader'

    onRender: ->
      self = @
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreUsers')
      $(window).scroll(@loadMoreUsers)
      @showLoading()
      @collection.search()

      @listenTo @collection, 'request', @showLoading
      @listenTo @collection, 'sync', @hideLoading

    showLoading: ->
      @ui.loading.show()

    hideLoading: ->
      @ui.loading.hide()

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      # $(window).unbind('scroll')

    loadMoreUsers: (e)->
      if @collection.nextPage == null
        @endPagination()
      else
        if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
          @reloadItems()

    reloadItems: ->
      search_options =
        page: @collection.nextPage
        remove: false
        reset: false
      @collection.search_by_last_query(search_options)

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

    onChildviewCatchUp: ->
      search_term: @search_term
      view = @
      @collection.fetch
        success: (model)->
          view.render()

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