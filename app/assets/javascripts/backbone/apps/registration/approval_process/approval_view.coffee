@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->

  class Main.LayoutView extends Marionette.LayoutView
    template: 'registration/approval_process/templates/layout'

   
    regions:
      sent_request_region: '#sent-request-region'
      approved_request_region: '#approved-request-region'
      find_people_region: '#find-people-region'
      suggested_region : '#suggested-region'

    views:
      sent_request_view: ""
      approved_request_view: ""

    onRender:->
      @sentRequest()
      @approvedRequest()
      @findUsers()
      @suggestedProfiles()

    sentRequest: ->  
      layout = @
      users = AlumNet.request("current_user:approval:sent", AlumNet.current_user.id)
      users.on 'sync:complete':->
        layout.views.sent_request_view = new Main.SentRequest    
          collection: users
          console.log users
        layout.sent_request_region.show(layout.views.sent_request_view)
  

    approvedRequest: ->
      layout = @

      friendsCollection = AlumNet.request('current_user:friendships:friends')
      friendsCollection.fetch()
        
      layout.views.approved_request_view = new  Main.ApprovedRequest      
        collection: friendsCollection
       
      layout.approved_request_region.show(layout.views.approved_request_view)

    findUsers: ->
      layout = @

      users = AlumNet.request('user:entities', {}, {fetch: false})

      find_users = new Main.FindUsers
        model: AlumNet.current_user
        collection: users

      layout.find_people_region.show(find_users)

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
          layout.views.sent_request_view.collection.fetch()
          $("#sent").show()
          $("#approved").show()
          $("#js-hr-requests").show()
    
    suggestedProfiles: ->
      layout = @
      usersSuggested = new AlumNet.Entities.SuggestedUsersCollection
      usersSuggested.fetch()

      suggested_profiles = new Main.SuggestedProfiles
        model: AlumNet.current_user
        layout: @
        collection: usersSuggested   

      layout.suggested_region.show(suggested_profiles)


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
          layout.views.sent_request_view.collection.fetch()
          $("#sent").show()
          $("#approved").show()
          $("#js-hr-requests").show()


   
  class Main.SentRequestUserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user_sent_request'

  class Main.ApprovedRequestUserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user_approved_request'

  class Main.UserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user'

    initialize: ->

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
    templateHelpers: ->
      @showSentRequest()

    showSentRequest: ()->
  
      countSentRequest = 0
      users = AlumNet.request("current_user:approval:sent", AlumNet.current_user.id)
      users.on 'sync:complete':->
        countSentRequest = users.length
        console.log countSentRequest
        if countSentRequest > 0
          $("#sent").show()
          $("#js-hr-requests").show()
          
  class Main.ApprovedRequest extends Marionette.CompositeView
    template: 'registration/approval_process/templates/approved_request'
    childView: Main.ApprovedRequestUserView
    childViewContainer: '.users-list'
  
    templateHelpers: ->
      @approvedRequestsCount()
      @showApprovedRequest()

    approvedRequestsCount: ()->

      approved_requests_count = 0
      i = 0

      friendsCollection = AlumNet.request('current_user:friendships:friends')
      friendsCollection.fetch
        success:->
          approved_requests_count = friendsCollection.length
          $("#approved_requests_count").html(approved_requests_count)
          html= ''
          for i in [approved_requests_count..2] 
            html = html + '<div class="userCardSentApproved">
                      <div class="row">
                        <div class="col-lg-3 col-md-4 col-sm-3 col-xs-3 userCardSentApproved__avatar">
                          <img src="/images/avatar/large_default_avatar.png" class="img-circle">
                        </div>
                        <div class="col-lg-9 col-md-8 col-sm-9 col-xs-9 userCardSentApproved__name--waiting">
                          <h4 class="overfloadText no-margin"><i>waiting... </i></h4>       
                          </p>
                        </div>
                      </div>
                    </div>'
          $("#waiting").html(html)

            
          


      approved_requests_count

    showApprovedRequest: ()->
  
      countSentRequest = 0;
      users = AlumNet.request("current_user:approval:sent", AlumNet.current_user.id)
      users.on 'sync:complete':->
        countSentRequest = users.length
        if countSentRequest > 0
          $("#approved").show()
          $("#js-hr-requests").show()
 
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
      'submit #search-form': 'performSearchKeyPress'

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

    performSearchKeyPress: (e) ->
      e.preventDefault()
      $("#search").show()
      
      data = Backbone.Syphon.serialize(this)
      console.log data
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
