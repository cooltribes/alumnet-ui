@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Layout extends Marionette.LayoutView
    template: 'admin/users/list/templates/layout'
    className: 'container'
    regions:
      modals:
        selector: '#modals-region'
        regionClass: Backbone.Marionette.Modals
      main: '#table-region'

    onShow: ->
      view = @
      users = AlumNet.request("admin:user:entities", {})
      users.fetch
        success: ->
          usersView = new Users.UsersTable
            collection: users
            modals: view.modals
          view.main.show(usersView)

  #----Modal para cambiar suscripcion
  class Users.ModalPremium extends Backbone.Modal
    template: 'admin/users/list/templates/modal_premium'

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      id = @model.id
      url = AlumNet.api_endpoint + "/users/#{id}/subscriptions"
      data.user_id = id

      Backbone.ajax
        url: url
        type: "POST"
        data: data
        success: (data) =>
          console.log("success")
          console.log(data)
        error: (data) =>
          console.log("error")
          console.log(data)

    onRender: ->
      @$(".js-date-start-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)

      @$(".js-date-end-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: 1
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)

  #----Modal para cambiar le status
  class Users.ModalStatus extends Backbone.Modal
    template: 'admin/users/list/templates/modal_status'

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      id = @model.id
      if data.status == "1"
        url = AlumNet.api_endpoint + "/admin/users/#{id}/activate"
      else
        url = AlumNet.api_endpoint + "/admin/users/#{id}/banned"

      Backbone.ajax
        url: url
        type: "PUT"
        success: (data) =>
          @model.set(data)
          @model.trigger 'change:role'
        error: (response) =>
          message = AlumNet.formatErrorsFromApi(response.responseJSON)
          $.growl.error(message: message)

  #----Modal para cambiar el rol
  class Users.ModalRole extends Backbone.Modal
    template: 'admin/users/list/templates/modal_role'

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-role"

    initialize: ->
      @model.set('roleText', @model.getRole())

    onRender: ->
      role = @model.getRole()
      @setSelectLocation(role, @model.get('admin_location'))

    events:
      'change select#role': 'displayLocations'

    displayLocations: (e)->
      role = $(e.currentTarget).val()
      @setSelectLocation(role)

    setSelectLocation: (role, value)->
      if role == "nacional"
        data = CountryList.toSelect2()
      else if role == "regional"
        data = AlumNet.request('get:regions:select2')
      else
        @.$('#js-location').select2('destroy')

      if data
        @.$('#js-location').select2
          placeholder: "Select Location"
          data: data
        if value
          @.$('#js-location').select2('data', value)

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      id = @model.id
      url = AlumNet.api_endpoint + "/admin/users/#{id}/change_role"
      Backbone.ajax
        url: url
        type: "PUT"
        data: data
        success: (data) =>
          @model.set(data)
          @model.trigger 'change:role'
        error: (response) =>
          message = AlumNet.formatErrorsFromApi(response.responseJSON)
          $.growl.error(message: message)


  #----Modal para cambiarle el plan de membresia a un user----
  class Users.ModalPlan extends Backbone.Modal
    template: 'admin/users/list/templates/modal_plan'

    viewContainer: '.my-container'
    cancelEl: '#close-btn'
    submitEl: "#save-status"



  class Users.UserView extends Marionette.ItemView
    template: 'admin/users/list/templates/_user'
    tagName: "tr"
    ui:
      'btnEdit': '.js-edit'
    events:
      'click @ui.btnEdit': 'showActions'
      'click #editPremium': 'openPremium'
      'click #editStatus': 'openStatus'
      'click #delete-user': 'deleteUser'
      'click #editRole': 'openRole'

    initialize: (options) ->
      @modals = options.modals
      @listenTo(@model, 'change:role', @modelChange)


    templateHelpers: () ->
      model = @model
      getRoleText: @model.getRole()

      getAge: ()->
        if @profileData.born
          return moment().diff(@profileData.born, 'years')
        "No age"

      getJoinTime: ()->
        moment(@created_at).fromNow()

      getOriginLocation: ()->
        if @profileData.birth_city
          return "#{@profileData.birth_city.text} - #{@profileData.birth_country.text}"
        "No origin location"

      getLC: ()->
        if @profileData.local_committee
          return @profileData.local_committee.name
        "No local committee"

      getEmail: ()->
        @email

      getName: ()->
        if @name.trim()
          return @name
        "No name registered"

      getGender: ()->
        if @profileData.gender
          return @profileData.gender
        "No gender"

      getId: () ->
        id = @model.id

      getLastSignIn: ->
        if model.get "last_sign_in_at"
          moment(model.get("last_sign_in_at")).format("MMM DD YY, h:mm:ss a")
        else
          ""
      getRegisterStep: ->
        @profileData.register_step

    modelChange: ->
      @render()

    deleteUser: (e)->
      e.preventDefault()
      resp = confirm("Do you really want to delete a user?")
      if resp
        @model.destroy()
        @modals.destroy() #Se debe llamar destroy en la region de los modals, no el modal como tal.

    openPremium: (e) ->
      e.preventDefault();

      statusView = new Users.ModalPremium
        model: @model
        modals: @modals

      @modals.show(statusView)

    openStatus: (e) ->
      e.preventDefault();

      statusView = new Users.ModalStatus
        model: @model
        modals: @modals

      @modals.show(statusView)

    openRole: (e) ->
      e.preventDefault();

      statusView = new Users.ModalRole
        model: @model
        modals: @modals

      @modals.show(statusView)


  class Users.UsersTable extends Marionette.CompositeView
    template: 'admin/users/list/templates/users_container'
    childView: Users.UserView
    childViewContainer: "#users-table tbody"
    queryParams: {}
    tagsParams: ''
    collectionFilter: ''
    childViewOptions: (model, index) ->
      modals: @modals

    initialize: (options) ->
      @modals = options.modals
      document.title= 'AlumNet - Users Management'
      @listenTo this, 'change:total', @updateTotal

    updateTotal: ->
      @ui.totalRecords.html(@collection.totalRecords)

    templateHelpers: ->
      view = @
      totalRecords: @collection.totalRecords
      pagination_buttons: ->
          class_li = ''
          class_link = ''
          html = ""
          if (view.collection.state.totalPages > 1)
            console.log "Páginas sin filtros: "+view.collection.state.totalPages
            html = '<nav id="pag"><ul class="pagination"><li><a href="#admin/users" id="prevButton" style="display:none">Prev</a></li>'
            for page in [1..view.collection.state.totalPages]
              if (page == 1)
                class_li = "active"
                class_link = "paginationUsers "
              else
                class_li = ""
                class_link = ""

              html += '<li class= "'+class_li+'" id='+page+'><a class= "page_button" href="#admin/users" id="link_'+page+'">'+page+'</a></li>  '

            html += '<li class="next"><a href="#admin/users" id="nextButton">Next</a></li></ul></nav>'
          html


    onShow: ->
      @pagination()
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "profile_first_name_or_profile_last_name", type: "string", values: "" },
        { attribute: "email", type: "string", values: "" },
        { attribute: "profile_residence_country_name", type: "string", values: "" },
        { attribute: "profile_birth_country_name", type: "string", values: "" }
        { attribute: "profile_residence_city_name", type: "string", values: "" }
        { attribute: "profile_birth_city_name", type: "string", values: "" }
        { attribute: "profile_gender", type: "option", values: [{value: "M", text: "Male"}, {value: "F", text: "Famale"}] }
        { attribute: "status", type: "option", values: [{value: 0, text: "Inactive"}, {value: 1, text: "Active"}, {value: 2, text: "Banned"}] }
        { attribute: "member", type: "option", values: [{value: 0, text: "Regular"}, {value: 1, text: "Member (1 year)"}, {value: 2, text: "Member(<= 30 days)"}, {value: 3, text: "Lifetime"}] }
        { attribute: "created_at", type: "date", values: "" }
        { attribute: "profile_experiences_committee_name", type: "string", values: "" }
        { attribute: "profile_register_step", type: "option", values: [{value: 0, text: "Basic Information"}, {value: 1, text: "Languajes and Skills"}, {value: 2, text: "Aiesec Experiences"}, {value: 3, text: "Completed"}] }
        { attribute: "sign_in_count", type: "numeric", values: "" }
      ])

    ui:
      #'prevButton': '#prevButton'
      #'nextButton': '#nextButton'
      'prevFilterButton': '#prevFilterButton'
      'nextFilterButton': '#nextFilterButton'
      'totalRecords': '.js-total-records'

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .search': 'advancedSearch'
      'click .clear': 'clear'
      'click #search-tags': 'searchTags'
      'change #filter-logic-operator': 'changeOperator'
      #'click .next > a': 'nextButton'
      #'click .prev > a': 'prevButton'
      'click #nextFilterButton': 'nextFilterButton'
      'click #prevFilterButton': 'prevFilterButton'
      'click #sortAge': 'sortAge'
      'click #sortJoined': 'sortJoined'
      'click #birth_city': 'sortBirtCity'
      #'click .page > a': 'toPageButton'
      'click .page_filter_button': 'toPageFilterButton'

    pagination: ->
      that = @
      $('#pagination').twbsPagination
          totalPages: 35
          visiblePages: 7
          onPageClick: (event, page) ->
            that.collection.queryParams.q = that.queryParams
            that.collection.getPage(page) 


    removeClass: ->
      view = @
      if (view.collection.state.totalPages > 1)
        for page in [1..view.collection.state.totalPages]
          $("#"+page).removeClass('active')
          $("#link_"+page).removeClass('paginationUsers')

    removeFilterClass: ->
      view = @
      if (view.collectionFilter.state.totalPages > 1)
        for page in [1..view.collectionFilter.state.totalPages]
          $("#"+page).removeClass('active')
          $("#link_"+page).removeClass('paginationUsers')

    addClass: (topage)->
      $("#"+topage).addClass('active')
      $("#link_"+topage).addClass('paginationUsers')

    sortBirtCity: (e)->
      @collection.queryParams.sort_by = "profiles.birth_city.name"
      if @collection.queryParams.order_by =='desc'
        @collection.queryParams.order_by = 'asc'
      else
        @collection.queryParams.order_by = 'desc'
      @collection.fetch()

    sortJoined: (e)->
      @collection.queryParams.sort_by = "created_at"
      if @collection.queryParams.order_by =='desc'
        @collection.queryParams.order_by = 'asc'
      else
        @collection.queryParams.order_by = 'desc'
      @collection.fetch()

    sortAge: (e)->
      @collection.queryParams.sort_by = "profiles.born"
      if @collection.queryParams.order_by =='desc'
        @collection.queryParams.order_by = 'asc'
      else
        @collection.queryParams.order_by = 'desc'
      @collection.fetch()

    #prevButton: (e)->
    #  @collection.queryParams.q = @queryParams
    #  @removeClass()
    #  @ui.nextButton.show()

    #  topage = parseInt(@collection.state.currentPage)-1
    #  @addClass(topage)

    #  if @collection.state.currentPage == 2
    #    @ui.prevButton.hide()
    #  @collection.getPreviousPage()

    prevFilterButton: (e)->
      #@collectionFilter.queryParams.q = @queryParams
      @removeFilterClass()
      @ui.nextFilterButton.show()

      topage = parseInt(@collectionFilter.state.currentPage)-1
      @addClass(topage)

      if @collectionFilter.state.currentPage == 2
        @ui.prevFilterButton.hide()
      @collectionFilter.getPreviousPage()

    #nextButton: (e)->
    #  console.log "entro"
    #  @collection.queryParams.q = @queryParams
    #  @removeClass()
    #  topage = parseInt(@collection.state.currentPage)+1

    #  if @tagsParams != '' then @collection.queryParams.tags = @tagsParams
    #  @ui.prevButton.show()
    #  @addClass(topage)
    #  if (@collection.state.currentPage == (@collection.state.totalPages-1))
    #    @addClass(topage)
    #    @ui.nextButton.hide()
    #  @collection.getNextPage()

    nextFilterButton: (e)->
      #@collectionFilter.queryParams.q = @queryParams
      @removeFilterClass()
      topage = parseInt(@collectionFilter.state.currentPage)+1

      if @tagsParams != '' then @collectionFilter.queryParams.tags = @tagsParams
      @ui.prevFilterButton.show()
      @addClass(topage)
      if (@collectionFilter.state.currentPage == (@collectionFilter.state.totalPages-1))
        @addClass(topage)
        @ui.nextFilterButton.hide()
      @collectionFilter.getNextPage()

    #toPageButton: (e)->
    #  @collection.queryParams.q = @queryParams
    #  topage = parseInt(e.currentTarget.innerText)
    #  @removeClass()

    #  if topage == 1
    #    @ui.prevButton.hide()
    #    @addClass(topage)
    #  else
    #    @ui.prevButton.show()
    #  if topage == @collection.state.totalPages
    #    @addClass(topage)
    #    @ui.nextButton.hide()
    #  else
    #    @ui.nextButton.show()
    #    @addClass(topage)

      @collection.getPage(topage)

    toPageFilterButton: (e)->
      console.log "toPageFilterButton"
      console.log @collectionFilter
      #@collectionFilter.queryParams.q = @queryParams
      topage = parseInt(e.currentTarget.innerText)
      @removeFilterClass()

      if topage == 1
        @ui.prevFilterButton.hide()
        @addClass(topage)
      else
        @ui.prevFilterButton.show()
      if topage == @collectionFilter.state.totalPages
        @addClass(topage)
        @ui.nextFilterButton.hide()
      else
        @ui.nextFilterButton.show()
        @addClass(topage)

      @collectionFilter.getPage(topage)

    pagination_filters: (collection) ->

      console.log "aqui"
      $("#pag-filter").remove()
      class_li = ''
      class_link = ''
      html = ""
      if (collection.state.totalPages > 1)
        console.log "Páginas con filtros: "+collection.state.totalPages
        html = '<nav id="pag-filter"><ul class="pagination"><li><a href="#admin/users" id="prevFilterButton" style="display:none">Prev</a></li>'
        for page in [1..collection.state.totalPages]
          if (page == 1)
            class_li = "active"
            class_link = "paginationUsers "
          else
            class_li = ""
            class_link = ""

          html += '<li class= "'+class_li+'" id='+page+'><a class= "page_filter_button" href="#admin/users" id="link_'+page+'">'+page+'</a></li>  '

        html += '<li><a href="#admin/users" id="nextFilterButton">Next</a></li></ul></nav>'
      $("#pagination-filter").append(html)


    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    searchTags: (e)->
      e.preventDefault()
      tags = @.$('#tags').val()
      @tagsParams = tags
      @collection.fetch
        data: { tags: tags }

    advancedSearch: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @queryParams = query
      view = @

      view.collection.fetch
        data: { q: query }
        success: (collection) ->
          view.trigger 'change:total'
          console.log 'success'
          console.log collection
          console.log "Cantidad: "+collection.state.totalPages
          @collectionFilter = collection
          console.log "success filter"
          console.log @collectionFilter
          if collection.state.totalPages >= 0
            console.log "Cantidad mayor a 0: "+collection.state.totalPages
            $("#pag").hide()
            $("#pag-filter").remove()
            if collection.state.totalPages > 1
              console.log "Es mayor a 1 y es "+ collection.state.totalPages
              view.pagination_filters(collection)

    clear: (e)->
      e.preventDefault()
      view = @
      @collection.fetch
        success: ->
          view.trigger 'change:total'

