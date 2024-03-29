@AlumNet.module 'PicturesApp.AlbumList', (AlbumList, @AlumNet, Backbone, Marionette, $, _) ->
  
  class AlbumList.AlbumView extends Marionette.ItemView
    template: 'pictures/albums/list/templates/_album'
    className: 'col-md-3 col-sm-6'
    
    triggers:
      'click .js-detail': "show:detail"
    
    events:
      'click .js-remove': "removeItem"
      'click .js-edit': "editAlbum"
      
    ui:
      "modalCont": "#js-modal-container"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit  



    editAlbum: (e)->
      e.preventDefault()

      modal = new AlbumList.AlbumModalForm
        model: @model
        view: @

      @ui.modalCont.html(modal.render().el)
 
    removeItem: (e)->
      e.preventDefault()
      if confirm("Are you sure you want to delete this album and all its photos?")
        @model.destroy
          wait: true
    

  class AlbumList.AlbumsView extends Marionette.CompositeView
    template: 'pictures/albums/list/templates/albums_container'
    childView: AlbumList.AlbumView
    emptyView: AlumNet.Utilities.EmptyView
    emptyViewOptions: 
      message: "There is no albums here"
    childViewContainer: '.albums-list'
    childViewOptions: ->
      userCanEdit: @userCanEdit
      

    ui:
      "modalCont": "#js-modal-container"  
    
    events:
      'click .js-create': 'createAlbum'

    initialize: (options)->
      @userCanEdit = options.userCanEdit


    templateHelpers: ->
      userCanEdit: @userCanEdit

    createAlbum: (e)->
      e.preventDefault()
      album = new AlumNet.Entities.Album

      modal = new AlbumList.AlbumModalForm
        model: album       
        view: this

      @ui.modalCont.html(modal.render().el)  

  class AlbumList.AlbumModalForm extends Backbone.Modal
    template: 'pictures/albums/list/templates/_createModal'

    cancelEl: '#js-close'
    submitEl: '#js-save'
    keyControl: false
    events:      
      'change #js-countries': 'setCities'

    initialize: (options)->
      @view = options.view
      
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    templateHelpers: ->
     
      currentYear: new Date().getFullYear()
 
      isNew: @model.isNew()

    onRender: ->
      #For date taken     

      @$(".js-date-taken").Zebra_DatePicker
        show_icon: false
        show_select_today: true
        view: 'years'
        direction: false
        default_position: 'below'
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)

      #For cities and countries
      data = CountryList.toSelect2()      

      @$("#js-cities").select2
        placeholder: "Select a City"
        data: []


      @$("#js-countries").select2
        placeholder: "Select a Country"
        data: data 

      if @model.getLocation()
        country = @model.get('country')
        city = @model.get('city')

        initialCity = if city then { id: city.id, name: city.text } else false
        @$('#js-countries').select2('val', country.id)

        @setSelect2Cities(country.id, initialCity)        
      

    setCities: (e)->
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
      @$('#js-cities').select2 options
      if !initialValue
        @$('#js-cities').select2 "val", 0

      
    
    beforeSubmit: ()->
      #Validations
      data = Backbone.Syphon.serialize this
      @model.set(data)
      @model.isValid(true)


    submit: ()->  
      @view.trigger "submit:album", @model