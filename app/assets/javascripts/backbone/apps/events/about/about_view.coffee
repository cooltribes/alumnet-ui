@AlumNet.module 'EventsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.Layout extends Marionette.LayoutView
    template: 'events/about/templates/layout'

    regions:
      info: '#about-info'
      map: '#about-map'

  class About.Map extends Marionette.ItemView
    template: 'events/about/templates/map'

    initialize: ->
      @listenTo(@model, 'change:location', @renderView)

    onDomRefresh: ->
      @renderMap()

    renderView: ->
      @render()

    renderMap: ->
      view = @
      @gMap = new GMaps
        div: '#map'
        lat: -27.116849
        lng: -109.364124

      GMaps.geocode
        address: @model.getLocation()
        callback: (results, status)->
          if status == 'OK'
            latlng = results[0].geometry.location
            view.gMap.setCenter(latlng.lat(), latlng.lng())
            view.gMap.addMarker
              lat: latlng.lat()
              lng: latlng.lng()

  class About.View extends Marionette.ItemView
    template: 'events/about/templates/about'

    initialize: (options)->
      @listenTo(@model, 'change:start_date change:end_date change:location change:admission_type', @renderView)
      @current_user = options.current_user

    templateHelpers: ->
      capacity = @model.get('capacity')
      admission_type: @model.get('admission_type')
      regular_price: @model.get('regular_price')
      premium_price: @model.get('premium_price')
      id: @model.get('id')
      currentUserIsAdmin: @current_user.isAlumnetAdmin()
      canEditInformation: @model.userIsAdmin()
      capacity_text: if capacity then capacity else '--'
      attendance_status: if @model.get('attendance_info') then @model.get('attendance_info').status else ""

    ui:
      'eventDescription':'#description'
      'eventAddress':'#address'
      'startDate':'#js-edit-start-date'
      'endDate':'#js-edit-end-date'
      'startHour':'#start_hour'
      'endHour':'#end_hour'
      'capacity': '#capacity'
      'regularPrice': '#regular_price'
      'premiumPrice': '#premium_price'
      'admisionType':'#admision_type'
      'Gmap': '#map'

    events:
      'click a#js-edit-description': 'toggleEditDescription'
      'click a#js-edit-capacity': 'toggleEditCapacity'
      'click a#js-edit-address': 'showModalLocation'
      'click a#js-edit-regular-price': 'toggleEditRegularPrice'
      'click a#js-edit-premium-price': 'toggleEditPremiumPrice'
      'click a#js-edit-admision_type': 'toggleEditAdmisionType'

    onRender: ->
      view = this
      @ui.eventDescription.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Enter the description of Event'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'Event description is required, must be less than 2048 characters'
          if $.trim(value).length >= 2048  
            'Event description is too large! Must be less than 2048 characters'  
        success: (response, newValue)->
          view.model.save({description: newValue})
      @ui.eventDescription.linkify()

      @ui.admisionType.editable
        type:'select'
        value: view.model.get('admission_type')    
        source: [
              {value: 0, text: 'Free'},
              {value: 1, text: 'Paid'}
           ]
        pk: view.model.id
        title: 'Enter the admision type of Event'
        toggle: 'manual'
        success: (response, newValue)->
          view.model.save({admission_type: newValue,premium_price: null,regular_price: null})
          view.model.trigger('change:admission_type')

      @ui.capacity.editable
        type: 'text'
        pk: view.model.id
        title: 'Enter the capacity of Event'
        toggle: 'manual'
        validate: (value)->
          unless /^\d+$/.test(value)
            'This field should be numeric'
        success: (response, newValue)->
          newValue = parseInt(newValue)
          view.model.save({capacity: newValue})

      @ui.regularPrice.editable
        type: 'text'
        pk: view.model.id
        title: 'Enter price for regular users'
        toggle: 'manual'
        validate: (value)->
          unless /^\d+(.\d{1,2})?$/.test(value)
            'This field should be numeric'
        success: (response, newValue)->
          view.model.save({regular_price: newValue})

      @ui.premiumPrice.editable
        type: 'text'
        pk: view.model.id
        title: 'Enter price for premium users'
        toggle: 'manual'
        validate: (value)->
          unless /^\d+(.\d{1,2})?$/.test(value)
            'This field should be numeric'
        success: (response, newValue)->
          view.model.save({premium_price: newValue})

      @ui.startDate.Zebra_DatePicker
        show_icon: false
        show_select_today: false
        pair: @ui.endDate
        show_clear_date: false
        default_position: 'below'
        onSelect: (dateFormated, dateRegular, dateJavaScript, element )->
          view.model.set('start_date', dateFormated)

      @ui.endDate.Zebra_DatePicker
        direction: 1
        show_icon: false
        show_select_today: false
        show_clear_date: false
        default_position: 'below'
        onSelect: (dateFormated, dateRegular, dateJavaScript, element )->
         view.model.set('end_date', dateFormated)

      @ui.startHour.clockpicker
        donetext: 'Select'
        autoclose: true
        afterDone: ->
          hour = view.ui.startHour.val()
          view.model.save { start_hour: hour }

      @ui.endHour.clockpicker
        donetext: 'Select'
        autoclose: true
        afterDone: ->
          hour = view.ui.endHour.val()
          view.model.save { end_hour: hour }

    toggleEditDescription: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.eventDescription.editable('toggle')

    toggleEditCapacity: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.capacity.editable('toggle')

    showModalLocation: (e)->
      e.preventDefault()
      modal = new About.ModalLocation
        model: @model #event
      $('#container-modal-location').html(modal.render().el)

    toggleEditRegularPrice: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.regularPrice.editable('toggle')

    toggleEditPremiumPrice: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.premiumPrice.editable('toggle')

    toggleEditAdmisionType: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.admisionType.editable('toggle')

    renderView: ->
      @model.save()
      @render()


  class About.ModalLocation extends Backbone.Modal
    template: 'events/about/templates/modal_location'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-delete': 'deleteClicked'
      'change .js-countries': 'selectCities'

    selectCities: (e)->
      @.$('.js-cities').val('')
      @setSelect2Cities(e.val, false)

    setSelect2Cities: (val, initialValue)->
      url = AlumNet.api_endpoint + '/countries/' + val + '/cities'
      options =
        placeholder: "Select a City"
        minimumInputLength: 2
        ajax:
          url: url
          dataType: 'json'
          data: (term)->
            q:
              name_cont: term
          results: (data, page) ->
            results:
              data
        formatResult: (data)->
          data.name
        formatSelection: (data)->
          data.name
        initSelection: (element, callback)->
          callback(initialValue) if initialValue
      @.$('.js-cities').select2 options

    saveClicked:(e)->
      e.preventDefault()
      modal = @
      model = @model
      rawData = Backbone.Syphon.serialize(modal)
      data = rawData
      @model.save data,
        success: ->
          model.trigger 'change:location'
          modal.destroy()

    onRender: ->
      data = CountryList.toSelect2()
      country = @model.get('country')
      city = @model.get('city')
      initialCity = { id: city.value, name: city.text }

      @.$('.js-countries').select2
        placeholder: "Select a Country"
        data: data

      @.$('.js-countries').select2('val', country.value)
      @setSelect2Cities(country.value, initialCity)
