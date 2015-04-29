@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Layout extends Marionette.LayoutView
    template: 'admin/users/list/templates/layout'
    className: 'container'
    regions:
      modals:
        selector: '#modals-region'
        regionClass: Backbone.Marionette.Modals
      filters: '#filters-region'
      main: '#table-region'


  #----Modal principal con las acciones----
  class Users.ModalActions extends Backbone.Modal
    template: 'admin/users/list/templates/modal_actions'

    cancelEl: '#close-btn'
    submitEl: "#save-status"

    events:
      'click #editPremium': 'openPremium'
      'click #editStatus': 'openStatus'
      'click #delete-user': 'deleteUser'
      'click #editRole': 'openRole'


    initialize: (options) ->
      @modals = options.modals

    deleteUser: (e)->
      e.preventDefault()
      resp = confirm("Are you sure?")
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

      console.log(data)

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
      min_date = moment().format("YYYY-MM-DD")
      max_date = moment().add(20, 'years').format("YYYY-MM-DD")
      @$(".js-date-start-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: [min_date, max_date]
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)

      @$(".js-date-end-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: [min_date, max_date]
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
        error: (data) =>
          text = data.responseJSON[0]
          $.growl.error({ message: text })

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
        error: (data) =>
          text = data.responseJSON[0]
          $.growl.error({ message: text })


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

    initialize: (options) ->
      @modals = options.modals
      @listenTo(@model, 'change:role', @modelChange)


    templateHelpers: () ->

      member= @model.member

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

    modelChange: ->
      @render()


    showActions: (e)->
      e.stopPropagation()
      e.preventDefault()

      modalsView = new Users.ModalActions
        model: @model
        modals: @modals

      @modals.show(modalsView)


  class Users.UsersTable extends Marionette.CompositeView
    template: 'admin/users/list/templates/users_container'
    childView: Users.UserView
    childViewContainer: "#users-table tbody"

    initialize: (options) ->
      @modals = options.modals

    childViewOptions: (model, index) ->
      modals: @modals




  ###Filters views###
  class Users.Filter extends Marionette.ItemView
    template: 'admin/users/list/templates/filter'
    tagName: "form"

    ui:
      'btnRmv': '.js-rmvRow'
      'field': 'input[name=field]'
      "selectType": ".filter_by"
      'me': 'el'
      
    events:
      "click @ui.btnRmv": "removeRow"
      "change .filter_by, click .filter_by" : "changeField"
      "sumbit me": "sumbitForm"

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    onRender: ->
      console.log  @ui.field.val()
      console.log  @ui.field
      @$(".js-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: ['2015-01-01', '2030-12-12']
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999) 
          
    comparatorOption: (comparator) ->
      if comparator == null || comparator == 0
        $('#comparator2').hide()
        $('#comparator1').show()    
      else if comparator == 1
        $('#comparator1').hide()    
        $('#comparator2').show()
    valueOption: (value) ->
      if value == null || value == 0
        $('#value2').hide()    
        $('#value3').hide()    
        $('#value4').hide()    
        $('#value5').hide()    
        $('#value1').show()
      else if value == 1
        $('#value1').hide()
        $('#value3').hide()    
        $('#value4').hide()    
        $('#value5').hide()  
        $('#value2').show()    
      else if value == 2
        $('#value1').hide()
        $('#value2').hide()    
        $('#value4').hide()    
        $('#value5').hide()
        $('#value3').show()
      else if value == 3
        $('#value1').hide()
        $('#value2').hide()    
        $('#value5').hide()
        $('#value3').hide()          
        $('#value4').show()    
                          

    changeField: (e) ->
      if @ui.selectType.val() =='profile_first_name_or_profile_last_name'
        @comparatorOption(0)
        @valueOption(0)        
      else if @ui.selectType.val() =='email'
        @comparatorOption(0)
        @valueOption(0)        
      else if @ui.selectType.val() =='profile_residence_country_name'
        console.log "country residence"
        @comparatorOption(0)
        @valueOption(0)
      else if @ui.selectType.val() =='profile_birth_country_name'
        console.log "birth country"
        @comparatorOption(0)
        @valueOption(0)       
      else if @ui.selectType.val() =='profile_residence_city_name'
        console.log "city residence"
        @comparatorOption(0)
        @valueOption(0)       
      else if @ui.selectType.val() =='profile_birth_city_name'
        console.log "birth city"
        @comparatorOption(0)
        @valueOption(0)
      else if @ui.selectType.val() =='profile_gender'
        console.log "gender"
        @comparatorOption(0)
        @valueOption(1)       
      else if @ui.selectType.val() =='created_at'   
        console.log "created at"
        @comparatorOption(1)
        @valueOption(2)

    sumbitForm: (e)->
      e.preventDefault()

    removeRow: (e)->
      @model.destroy()


  class Users.Filters extends Marionette.CompositeView
    template: 'admin/users/list/templates/filters_container'

    childView: Users.Filter
    childViewContainer: "#js-filters"

    ui:
      'btnAdd': '.js-addRow'
      'btnSearch': '.js-search'
      'btnReset': '.js-reset'
      'logicOp': '[name=logicOp]'

    events:
      "click @ui.btnAdd": "addRow"
      "click @ui.btnSearch": "search"
      "click @ui.btnReset": "reset"


    addRow: (e)->
      newFilter = new AlumNet.Entities.Filter
      @collection.add(newFilter)


    reset: (e)->
      @collection.reset()
      @trigger('filters:search')

    search: (e)->
      e.preventDefault()
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
      @trigger('filters:search')



    # initialize: (options) ->
    #   @modals = options.modals

