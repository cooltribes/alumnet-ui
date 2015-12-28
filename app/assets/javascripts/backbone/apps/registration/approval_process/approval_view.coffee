@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->

  class Main.LayoutView extends Marionette.LayoutView
    template: 'registration/approval_process/templates/layout'
    className: 'container-fluid'
   
    regions:
      sent_request_region: '#sent-request-region'
      approved_request_region: '#approved-request-region'
      find_people_region: '#find-people-region'
      suggested_region : '#suggested-region'

    initialize: ->
    
    onRender:->

      usersSentRequest = AlumNet.request('user:entities', {}, {fetch: false})    
      console.log usersSentRequest
      sent_request = new Main.SentRequest
        model: AlumNet.current_user
        layout: @
        collection: usersSentRequest
      @sent_request_region.show(sent_request)

      usersApprovedRequest = AlumNet.request('user:entities', {}, {fetch: false})    
      approved_request = new Main.ApprovedRequest
        model: AlumNet.current_user
        layout: @
        collection: usersApprovedRequest
      @approved_request_region.show(approved_request)

      users = AlumNet.request('user:entities', {}, {fetch: false})


      find_users = new Main.FindUsers
        model: AlumNet.current_user
        layout: @
        collection: users

      @find_people_region.show(find_users)

      find_users.on 'users:search', (querySearch)->
        AlumNet.request('user:entities', querySearch)

      find_users.on 'contacts:search', (contacts)->
        find_users.collection = new AlumNet.Entities.ContactsInAlumnet
        find_users.collection.fetch({ method: 'POST', data: { contacts: contacts }})
        find_users.render()

      find_users.on 'request:admin', ()->
        url = AlumNet.api_endpoint + "/me/approval_requests/notify_admins"
        Backbone.ajax
          url: url
          type: "PUT"

      find_users.on 'childview:request', (childView)->
        childView.ui.actionsContainer.html('Sending request...')

        userId = childView.model.id
        approvalR = AlumNet.request("current_user:approval:request", userId)
        approvalR.on "save:success", ()->
          childView.ui.actionsContainer.html('Your request has been sent <span class="icon-entypo-paper-plane"></span>')
    
      usersSuggested = AlumNet.request('user:entities', {}, {fetch: false})
      suggested_profiles = new Main.SuggestedProfiles
        model: AlumNet.current_user
        layout: @
        collection: usersSuggested

      @suggested_region.show(suggested_profiles)

      suggested_profiles.on 'users:search', (querySearch)->
        AlumNet.request('user:entities', querySearch)

      suggested_profiles.on 'contacts:search', (contacts)->
        suggested_profiles.collection = new AlumNet.Entities.ContactsInAlumnet
        suggested_profiles.collection.fetch({ method: 'POST', data: { contacts: contacts }})
        suggested_profiles.render()

      suggested_profiles.on 'request:admin', ()->
        url = AlumNet.api_endpoint + "/me/approval_requests/notify_admins"
        Backbone.ajax
          url: url
          type: "PUT"

      suggested_profiles.on 'childview:request', (childView)->
        childView.ui.actionsContainer.html('Sending request...')

        userId = childView.model.id
        approvalR = AlumNet.request("current_user:approval:request", userId)
        approvalR.on "save:success", ()->
          childView.ui.actionsContainer.html('Your request has been sent <span class="icon-entypo-paper-plane"></span>')
  
  class Main.SentRequestUserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user_sent_request'

  class Main.ApprovedRequestUserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user_approved_request'

  class Main.UserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user'

    initialize: ->
      console.log @model

    ui:
      'requestBtn': '.js-ask'
      'actionsContainer': '.js-actions-container'

    events:
      'click @ui.requestBtn':'clickedRequest'

    clickedRequest: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request")

  class Main.SentRequest extends Marionette.CompositeView
    template: 'registration/approval_process/templates/sent_request'
    childView: Main.SentRequestUserView
    childViewContainer: '.users-list'

  class Main.ApprovedRequest extends Marionette.CompositeView
    template: 'registration/approval_process/templates/approved_request'
    childView: Main.ApprovedRequestUserView
    childViewContainer: '.users-list'

  class Main.ApprovalView extends Marionette.CompositeView
    template: 'registration/approval_process/templates/form'
    childView: Main.UserView
    childViewContainer: '.users-list'

    ui:
      'adminRequestBtn': '.js-askAdmin'
      selectResidenceCountries: "#js-residence-countries"

    events:
      'click .js-search': 'performSearch'
      'click @ui.adminRequestBtn':'clickedRequestAdmin'

    initialize: ->
       
      document.title = " AlumNet - Registration"
      @layout = options.layout

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
        afterInit: ()->
          links = document.getElementsByClassName('delayed');
          for link in links
            link.href = '#'
        beforeDisplayContacts: (contacts, source, owner)->
          view.formatContact(contacts)
          false

    onRender: ()->
      $('body,html').animate({scrollTop: 20}, 600);
      data = CountryList.toSelect2()
      @ui.selectResidenceCountries.select2
        placeholder: "Select a Country"
        data: data
      # @ui.selectResidenceCountries.select2('val', @model.profile.get('residence_country').id)

    clickedRequestAdmin: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request:admin")
      @ui.adminRequestBtn.parent().empty().html('Your request has been sent to an administrator. You will receive an e-mail notification once your Alumni status had been verified <span class="icon-entypo-paper-plane"></span>')

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', @buildQuerySearch(data))

    buildQuerySearch: (data) ->
      q:
        m: 'or'
        profile_first_name_or_profile_last_name_or_email_cont_any: data.search_term.split(" ")
        # profile_residence_country_id_eq: data.residence_country_id

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

    showMore: (e)->
      e.preventDefault()
      @collection.fetch
        success: ->
          $('#showMore').hide()
          @bandera = false

  class Main.FindUsers extends Marionette.CompositeView
    template: 'registration/approval_process/templates/find_users'
    childView: Main.UserView
    childViewContainer: '.users-list-search'

    ui:
      'adminRequestBtn': '.js-askAdmin'
      selectResidenceCountries: "#js-residence-countries"

    events:
      'click .js-search': 'performSearch'
      'click @ui.adminRequestBtn':'clickedRequestAdmin'

    initialize: ->
       
      document.title = " AlumNet - Registration"
      @layout = options.layout

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
        afterInit: ()->
          links = document.getElementsByClassName('delayed');
          for link in links
            link.href = '#'
        beforeDisplayContacts: (contacts, source, owner)->
          view.formatContact(contacts)
          false

    onRender: ()->
      $('body,html').animate({scrollTop: 20}, 600);
      data = CountryList.toSelect2()
      @ui.selectResidenceCountries.select2
        placeholder: "Select a Country"
        data: data
      # @ui.selectResidenceCountries.select2('val', @model.profile.get('residence_country').id)

    clickedRequestAdmin: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request:admin")
      @ui.adminRequestBtn.parent().empty().html('Your request has been sent to an administrator. You will receive an e-mail notification once your Alumni status had been verified <span class="icon-entypo-paper-plane"></span>')

    performSearch: (e) ->
      e.preventDefault()
     
      $("#search").show()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', @buildQuerySearch(data))

    buildQuerySearch: (data) ->
      q:
        m: 'or'
        profile_first_name_or_profile_last_name_or_email_cont_any: data.search_term.split(" ")
        # profile_residence_country_id_eq: data.residence_country_id

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

    showMore: (e)->
      e.preventDefault()
      @collection.fetch
        success: ->
          $('#showMore').hide()
          @bandera = false

  class Main.SuggestedProfiles extends Marionette.CompositeView
    
    template: 'registration/approval_process/templates/suggested_profiles'
    childView: Main.UserView
    childViewContainer: '.users-list'

    ui:
      'adminRequestBtn': '.js-askAdmin'
      selectResidenceCountries: "#js-residence-countries"

    events:
      'click .js-search': 'performSearch'
      'click @ui.adminRequestBtn':'clickedRequestAdmin'

    initialize: ->
       
      document.title = " AlumNet - Registration"
      @layout = options.layout

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
        afterInit: ()->
          links = document.getElementsByClassName('delayed');
          for link in links
            link.href = '#'
        beforeDisplayContacts: (contacts, source, owner)->
          view.formatContact(contacts)
          false

    onRender: ()->
      $('body,html').animate({scrollTop: 20}, 600);
      data = CountryList.toSelect2()
      @ui.selectResidenceCountries.select2
        placeholder: "Select a Country"
        data: data
      # @ui.selectResidenceCountries.select2('val', @model.profile.get('residence_country').id)

    clickedRequestAdmin: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request:admin")
      @ui.adminRequestBtn.parent().empty().html('Your request has been sent to an administrator. You will receive an e-mail notification once your Alumni status had been verified <span class="icon-entypo-paper-plane"></span>')

    performSearch: (e) ->
      e.preventDefault()
     
      $("#search").show()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', @buildQuerySearch(data))

    buildQuerySearch: (data) ->
      q:
        m: 'or'
        profile_first_name_or_profile_last_name_or_email_cont_any: data.search_term.split(" ")
        # profile_residence_country_id_eq: data.residence_country_id

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

    showMore: (e)->
      e.preventDefault()
      @collection.fetch
        success: ->
          $('#showMore').hide()
          @bandera = false
