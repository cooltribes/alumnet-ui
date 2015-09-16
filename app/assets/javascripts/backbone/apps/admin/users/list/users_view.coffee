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
    childViewOptions: (model, index) ->
      modals: @modals

    initialize: (options) ->
      @modals = options.modals
      document.title= 'AlumNet - Users Management'

    onShow: ->
      console.log "show"
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "profile_first_name_or_profile_last_name", type: "string", values: "" },
        { attribute: "email", type: "string", values: "" },
        { attribute: "profile_residence_country_name", type: "string", values: "" },
        { attribute: "profile_birth_country_name", type: "string", values: "" }
        { attribute: "profile_residence_city_name", type: "string", values: "" }
        { attribute: "profile_birth_city_name", type: "string", values: "" }
        { attribute: "profile_gender", type: "option", values: [{value: "M", text: "Male"}, {value: "F", text: "Famale"}] }
        { attribute: "status", type: "option", values: [{value: 0, text: "Inactive"}, {value: 1, text: "Active"}, {value: 2, text: "Banned"}] }
        { attribute: "member", type: "string", values: "" }
        { attribute: "created_at", type: "date", values: "" }
        { attribute: "profile_experience_local_committee_name", type: "string", values: "" }
      ])

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .search': 'advancedSearch'
      'click .clear': 'clear'
      'click #search-tags': 'searchTags'
      'change #filter-logic-operator': 'changeOperator'

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
      @collection.fetch
        data: { tags: tags }

    advancedSearch: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @collection.fetch
        data: { q: query }

    clear: (e)->
      e.preventDefault()
      @collection.fetch()