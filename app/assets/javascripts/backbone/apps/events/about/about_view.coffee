@AlumNet.module 'EventsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.ItemView
    template: 'events/about/templates/about'

    initialize: (options)->
      @listenTo(@model, 'change:start_date change:end_date', @renderView)
      @current_user = options.current_user

    templateHelpers: ->
      model = @model
      currentUserIsAdmin: @current_user.isAlumnetAdmin()
      canEditInformation: @model.userIsAdmin()

    ui:
      'eventDescription':'#description'
      'eventAddress':'#address'
      'startDate':'#js-edit-start-date'
      'endDate':'#js-edit-end-date'
      'Gmap': '#map'

    events:
      'click a#js-edit-description': 'toggleEditDescription'
      'click a#js-edit-address': 'toggleEditAddress'

    onRender: ->
      view = this
      @ui.eventDescription.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Enter the description of Event'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.model.save({description: newValue})

      @ui.eventAddress.editable
        type: 'text'
        pk: view.model.id
        title: 'Enter new Address'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.model.save({address: newValue})

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

    onShow: ->
      @renderMap()

    toggleEditDescription: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.eventDescription.editable('toggle')

    toggleEditAddress: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.eventAddress.editable('toggle')

    renderView: ->
      @model.save()
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