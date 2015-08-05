@AlumNet.module 'CompaniesApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  #Si son regiones utilizo layout
  class About.Layout extends Marionette.LayoutView
    template: 'companies/about/templates/about'
    className: 'container'

    regions:
       details: "#details"
       services: "#services"
       contacts: "#contacts"
       branches: "#branches"

    events:
      'click .smoothClick':'smoothClick'

    initialize: ->
       $(window).on 'scroll' , =>
         if $('body').scrollTop()>500
           $('#companyBusinessAffix').css
             'position': 'fixed'
             'width' : '265px'
             'top' : '120px'
         else
           if $('html').scrollTop()>500
             $('#companyBusinessAffix').css
               'position': 'fixed'
               'width' : '265px'
               'top' : '120px'
           else
             $('#companyBusinessAffix').css
               'position': 'relative'
               'top':'0px'
               'width':'100%'

    smoothClick: (e)->
      if $(e.target).prop("tagName")!='a'
        element = $(e.target).closest 'a'
      else
        element = e.target
      String id = $(element).attr("id")
      id = '#'+id.replace('to','')
      $('html,body').animate({
        scrollTop: $(id).offset().top-120
      }, 1000);

  class About.DetailsView extends Marionette.CompositeView
    template: 'companies/about/templates/details'
    className: 'container-fluid'

    templateHelpers: ->
      userCanEdit: @model.userIsAdmin()
      employees_count: @model.employees_count()

    ui:
      'companyDescription': '#description'
      'companySize': '#size'
      'companySector': '#sector'

    events:
      'click #js-edit-company-description': 'toggleEditDescription'
      'click #js-edit-company-size': 'toggleEditSize'
      'click #js-edit-company-sector': 'toggleEditSector'

    toggleEditDescription: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.companyDescription.editable('toggle')

    toggleEditSize: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.companySize.editable('toggle')

    toggleEditSector: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.companySector.editable('toggle')

    fillEditableSectors: (data)->
      view = @
      @ui.companySector.editable
        type: 'select'
        value: view.model.get('sector').value
        pk: view.model.id
        title: 'Enter the Industry of Company'
        toggle: 'manual'
        source: data
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.model.save { sector_id: newValue }

    onRender: ->
      view = @
      @ui.companyDescription.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Enter the description of Company'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'Description is required, must be less than 2048 characters'
          if $.trim(value).length >= 2048
            'Description is too large! Must be less than 2048 characters'
        success: (response, newValue)->
          view.model.save { description: newValue }

      @ui.companySize.editable
        type: 'select'
        value: view.model.get('size').value
        pk: view.model.id
        title: 'Enter the size of Company'
        toggle: 'manual'
        source: view.model.sizes
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.model.save { size: newValue }

        ##fill sectors
        Backbone.ajax
          url: AlumNet.api_endpoint + '/sectors'
          success: (data)->
            values = []
            _.each data, (element, list)->
              values.push { value: element.id, text: element.name }
            view.fillEditableSectors(values)


  class About.ServiceView extends Marionette.CompositeView
    template: 'companies/about/templates/_product_service'
    tagName: 'li'

    initialize: (options)->
      options
      @company = options.company

    templateHelpers: ->
      userCanEdit: true #@company.userIsAdmin()

  class About.ServicesView extends Marionette.CompositeView
    template: 'companies/about/templates/services'
    className: 'container-fluid'
    childView: About.ServiceView
    childViewContainer: '.products_services'
    childViewOptions:
      company: @model

    ui:
      'saveLink': '#js-save-service'
      'inputName': 'input#name'

    events:
      'click @ui.saveLink': 'saveClicked'

    initialize: ->
      @collection.fetch()

    templateHelpers: ->
      userCanEdit: @model.userIsAdmin()

    saveClicked: (e)->
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      unless data.name == ""
        data.service_type = 0
        data.company_id = @model.id
        service = new AlumNet.Entities.Service data
        service.save {},
          success: (model)->
            view.collection.add(model)
            view.ui.inputName.val("")
          error: (model)->
            console.log "error"

  class About.ContactsView extends Marionette.CompositeView
    template: 'companies/about/templates/contacts'
    className: 'container-fluid'

  class About.BranchesView extends Marionette.CompositeView
    template: 'companies/about/templates/branches'
    className: 'container-fluid'