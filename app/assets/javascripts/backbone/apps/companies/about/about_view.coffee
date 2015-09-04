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
       links: "#links"

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
        emptytext: "There is not available information"
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


  #### SERVICES ####

  class About.ServiceView extends Marionette.ItemView
    template: 'companies/about/templates/_product_service'
    tagName: 'li'

    initialize: (options)->
      @company = options.company

    templateHelpers: ->
      userCanEdit: @company.userIsAdmin()

    ui:
      'deleteLink':'#js-delete-service'

    events:
      'click @ui.deleteLink': 'deleteClicked'

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm "Are you sure?"
      if resp
        @model.destroy()

  class About.ServicesView extends Marionette.CompositeView
    template: 'companies/about/templates/services'
    className: 'container-fluid'
    childView: About.ServiceView
    childViewContainer: '#js-products-services-list'
    childViewOptions: ->
      company: @model

    ui:
      'saveLink': '#js-save-service'
      'inputName': 'input#name'

    events:
      'click @ui.saveLink': 'saveClicked'

    templateHelpers: ->
      userCanEdit: @model.userIsAdmin()

    onShow: ->
      services = new Bloodhound
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
        queryTokenizer: Bloodhound.tokenizers.whitespace
        prefetch: AlumNet.api_endpoint + '/product_services/'
        remote:
          wildcard: '%query'
          url: AlumNet.api_endpoint + '/product_services/?q[name_cont]=%query'

      @ui.inputName.typeahead null,
        name: 'services'
        display: 'name'
        source: services

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


  #### CONTACTS ####

  class About.ContactModal extends Backbone.Modal
    template: 'companies/about/templates/contact_modal'
    cancelEl: '#cancel'
    keyControl: false

    initialize: (options)->
      @parentView = options.parentView
      Backbone.Validation.bind this,
      valid: (view, attr, selector) ->
        view.clearErrors(attr)
      invalid: (view, attr, error, selector) ->
        view.addErrors(attr, error)

    events:
      'click #save': 'saveClicked'

    onRender: ->
      view = @
      @.$('#contact-type').select2
        data: @model.contactTypesToSelect2()
      @.$('#contact-type').on 'change', (e)->
        contact = view.model.findContactType(e.val)
        view.changePlaceholder(contact.placeholder) if contact
      unless @model.isNew()
        @.$('#contact-type').select2('val', @model.get('contact_type'))

    clearErrors: (attr)->
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-contact')
      $group.removeClass('has-error')
      $group.find('.help-block').html('').addClass('hidden')

    addErrors: (attr, error)->
      console.log attr, error
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-contact')
      $group.addClass('has-error')
      $group.find('.help-block').html(error).removeClass('hidden')

    changePlaceholder: (text)->
      @.$('input#info').attr('placeholder', text)

    saveClicked: (e)->
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.set(data)
      if @model.isValid(true)
        view.parentView.collection.create @model,
          success: (model)->
            view.model.clear({silent: true})
            view.destroy()
          error: (model, response)->
            errors = response.responseJSON
            _.each errors, (value, key, list)->
              view.clearErrors(key)
              view.addErrors(key, value[0])

  class About.AddressModal extends Backbone.Modal
    template: 'companies/about/templates/address_modal'
    cancelEl: '#cancel'
    keyControl: false


    initialize: (options)->
      @contactsView = options.contactsView

    events:
      'change #country_id': 'setCities'
      'click #save': 'saveClicked'

    templateHelpers: ->
      model = @model
      city_helper: if @model.get('city') then @model.get('city').value

    onRender: ->
      @.$('#city_id').select2
        placeholder: "Select a City"
        data: []
      @.$('#country_id').select2
        placeholder: "Select a Country"
        data: CountryList.toSelect2()

      ## set initial value
      unless @model.isNew()
        @.$('#country_id').select2('val', @model.get('country').value)
        @setSelectCities(@model.get('country').value)

    setCities: (e)->
      @.$('#city_id').select2('val', {})
      @setSelectCities(e.val)

    setSelectCities: (country_id)->
      if @model.get('city')
        initialValue = { id: @model.get('city').value, name: @model.get('city').text }
      else
        initialValue = false

      url = AlumNet.api_endpoint + '/countries/' + country_id + '/cities'
      @.$('#city_id').select2
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

    saveClicked: (e)->
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.save data,
        success: (model)->
          view.destroy()
          view.contactsView.model.trigger('change:main_address')
          view.contactsView.changeLocation()
        error: (model, response)->
          console.log response

  class About.ContactView extends Marionette.ItemView
    template: 'companies/about/templates/_contact'

    initialize: (options)->
      @parentView = options.parentView
      @company = options.company
      @listenTo(@model, 'change', @renderView)


    templateHelpers: ->
      model = @model
      userCanEdit: @company.userIsAdmin()
      contactTypeText: (contact_type)->
        model.findContactType(contact_type) if model

    ui:
      'editLink':'#js-edit-contact'
      'deleteLink':'#js-delete-contact'

    events:
      'click @ui.deleteLink': 'deleteClicked'
      'click @ui.editLink': 'editClicked'

    renderView: ->
      @render()

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm "Are you sure?"
      if resp
        @model.destroy()

    editClicked: (e)->
      e.preventDefault()
      modal = new About.ContactModal
        model: @model
        parentView: @parentView
      $('#js-modal-contact-container').html(modal.render().el)

  class About.ContactsView extends Marionette.CompositeView
    template: 'companies/about/templates/contacts'
    className: 'container-fluid'
    childView: About.ContactView
    childViewContainer: '#js-contacts-container'
    childViewOptions: ->
      parentView: @
      company: @model

    initialize: ->
      @collection.url = AlumNet.api_endpoint + "/companies/#{@model.id}/contact_infos"
      @listenTo(@model, 'change:main_address', @renderView)

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

    templateHelpers: ->
      userCanEdit: @model.userIsAdmin()
      location: @model.getLocation()

    events:
      'click #js-edit-company-address': 'modalEditAddress'
      'click #js-add-contact': 'modalAddContact'

    modalAddContact: (e)->
      e.preventDefault()
      contact = new AlumNet.Entities.ProfileContact
      modal = new About.ContactModal
        model: contact
        parentView: @
      $('#js-modal-contact-container').html(modal.render().el)

    modalEditAddress: (e)->
      e.preventDefault()
      modal = new About.AddressModal
        model: @model
        contactsView: @
      $('#js-modal-address-container').html(modal.render().el)

    changeLocation: ->
      $('#js-location').html(@model.getLocation())


  #### BRANCHES ####

  class About.BranchesLayout extends Marionette.LayoutView
    template: 'companies/about/templates/branches_layout'
    className: 'container-fluid'

    regions:
       details: "#js-branch-detail"
       list: "#js-branches"

    onShow: ->
      branches = new About.BranchesView
        model: @model
        collection: @model.branchesCollection()
        layout: @
      @list.show(branches)

      if @model.branchesCollection().length > 0
        branch = @model.branchesCollection().at(0)
        @renderDetail(branch)

    renderDetail: (model)->
      @details.empty()
      contacts = new AlumNet.Entities.ProfileContactsCollection
      contacts.url = AlumNet.api_endpoint + "/branches/#{model.id}/contact_infos"
      contacts.fetch()
      detailView = new About.BranchDetail
        model: model
        company: @model
        collection: contacts
      @details.show(detailView)


  class About.BranchView extends Marionette.ItemView
    template: 'companies/about/templates/_branch'
    tagName: 'li'


    initialize: (options)->
      @company = options.company
      @branchesView = options.branchesView
      @layout = options.layout

    templateHelpers: ->
      location: @model.getLocation()
      userCanEdit: @company.userIsAdmin()

    ui:
      'deleteLink':'#js-delete-branch'
      'editLink':'#js-edit-branch'
      'showLink':'#js-show-branch'

    events:
      'click @ui.deleteLink': 'deleteClicked'
      'click @ui.editLink': 'editClicked'
      'click @ui.showLink': 'showClicked'

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm "Are you sure?"
      if resp
        @model.destroy()

    editClicked: (e)->
      e.preventDefault()
      modal = new About.BranchModal
        model: @model
        branchesView: @branchesView
      $('#js-modal-branch-container').html(modal.render().el)

    showClicked: (e)->
      e.preventDefault()
      @layout.renderDetail(@model)

  class About.BranchModal extends Backbone.Modal
    template: 'companies/about/templates/branch_modal'
    cancelEl: '#cancel'
    keyControl: false


    initialize: (options)->
      @branchesView = options.branchesView

    events:
      'change #country_id': 'setCities'
      'click #save': 'saveClicked'

    templateHelpers: ->
      model = @model
      city_helper: if @model.get('city') then @model.get('city').value

    onRender: ->
      @.$('#city_id').select2
        placeholder: "Select a City"
        data: []
      @.$('#country_id').select2
        placeholder: "Select a Country"
        data: CountryList.toSelect2()

      ## set initial value
      unless @model.isNew()
        @.$('#country_id').select2('val', @model.get('country').value)
        @setSelectCities(@model.get('country').value)

    setCities: (e)->
      @.$('#city_id').select2('val', {})
      @setSelectCities(e.val)

    setSelectCities: (country_id)->
      if @model.get('city')
        initialValue = { id: @model.get('city').value, name: @model.get('city').text }
      else
        initialValue = false

      url = AlumNet.api_endpoint + '/countries/' + country_id + '/cities'
      @.$('#city_id').select2
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

    saveClicked: (e)->
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.save data,
        success: (model)->
          view.model = null
          view.destroy()
          view.branchesView.collection.add(model)
          view.branchesView.render()
          model.trigger('change:location')
        error: (model, response)->
          console.log response

  class About.BranchesView extends Marionette.CompositeView
    template: 'companies/about/templates/branches'
    childView: About.BranchView
    childViewContainer: '#js-branches-list'
    childViewOptions: ->
      branchesView: @
      company: @model
      layout: @layout

    initialize: (options)->
      @layout = options.layout

    templateHelpers: ->
      userCanEdit: @model.userIsAdmin()

    events:
      'click #js-add-branch': 'modalAddBranch'

    modalAddBranch: (e)->
      e.preventDefault()
      branch = new AlumNet.Entities.Branch
      branch.url = AlumNet.api_endpoint + "/companies/#{@model.id}/branches"
      modal = new About.BranchModal
        model: branch
        branchesView: @
      $('#js-modal-branch-container').html(modal.render().el)

  class About.BranchDetail extends Marionette.CompositeView
    template: 'companies/about/templates/branch_detail'
    childView: About.ContactView
    childViewContainer: '#js-branch-contacts-container'
    childViewOptions: ->
      parentView: @
      company: @company

    initialize: (options)->
      @company = options.company
      @listenTo(@model, 'change:location', @renderView)

    templateHelpers: ->
      location: @model.getLocation(true)
      userCanEdit: @company.userIsAdmin()

    onDomRefresh: ->
      @renderMap()

    renderView: ->
      @render()

    renderMap: ->
      view = @
      @gMap = new GMaps
        div: '#detail-map'
        lat: -27.116849
        lng: -109.364124
        width: "100%"
        height: "320px"

      GMaps.geocode
        address: @model.getLocation(true)
        callback: (results, status)->
          if status == 'OK'
            latlng = results[0].geometry.location
            view.gMap.setCenter(latlng.lat(), latlng.lng())
            view.gMap.addMarker
              lat: latlng.lat()
              lng: latlng.lng()

    events:
      'click #js-add-branch-contact': 'modalAddContact'

    modalAddContact: (e)->
      e.preventDefault()
      contact = new AlumNet.Entities.ProfileContact
      modal = new About.ContactModal
        model: contact
        parentView: @
      $('#js-modal-branch-contact-container').html(modal.render().el)


  #### LINKS


  class About.LinkModal extends Backbone.Modal
    template: 'companies/about/templates/link_modal'
    cancelEl: '#cancel'
    keyControl: false

    initialize: (options)->
      @parentView = options.parentView
      Backbone.Validation.bind @,
        valid: (view, attr, selector) ->
          view.clearErrors(view, attr)
        invalid: (view, attr, error, selector) ->
          view.clearErrors(view, attr)
          view.addErrors(view, attr, error)

    events:
      'click #save': 'saveClicked'

    templateHelpers: ->
      model = @model

    clearErrors: (view, attr)->
      $el = view.$("[name=#{attr}]")
      $group = $el.closest('.form-link')
      $group.removeClass('has-error')
      $group.find('.help-block').html('').addClass('hidden')

    addErrors: (view, attr, error)->
      $el = view.$("[name=#{attr}]")
      $group = $el.closest('.form-link')
      $group.addClass('has-error')
      $group.find('.help-block').html(error).removeClass('hidden')

    saveClicked: (e)->
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.set(data)
      if @model.isValid(true)
        @model.save {},
          success: (model)->
            view.parentView.collection.add(model)
            view.model = null
            view.destroy()
          error: (model, response)->
            errors = response.responseJSON
            _.each errors, (value, key, list)->
              view.clearErrors(view, key)
              view.addErrors(view, key, value[0])

  class About.LinkView extends Marionette.ItemView
    template: 'companies/about/templates/_link'

    initialize: (options)->
      @company = options.company
      @parentView = options.parentView
      @listenTo(@model, 'change', @renderView)

    templateHelpers: ->
      model = @model
      userCanEdit: @company.userIsAdmin()

    ui:
      'editLink':'#js-edit-link'
      'deleteLink':'#js-delete-link'

    events:
      'click @ui.deleteLink': 'deleteClicked'
      'click @ui.editLink': 'editClicked'

    renderView: ->
      @render()

    deleteClicked: (e)->
      e.preventDefault()
      resp = confirm "Are you sure?"
      if resp
        @model.destroy()

    editClicked: (e)->
      e.preventDefault()
      modal = new About.LinkModal
        model: @model
        parentView: @parentView
      $('#js-modal-link-container').html(modal.render().el)

  class About.LinksView extends Marionette.CompositeView
    template: 'companies/about/templates/links'
    className: 'container-fluid'
    childView: About.LinkView
    childViewContainer: '#js-links-list'
    childViewOptions: ->
      company: @model
      parentView: @

    ui:
      'addLink': '#js-add-link'

    events:
      'click @ui.addLink': 'modalAddLink'

    templateHelpers: ->
      userCanEdit: @model.userIsAdmin()

    modalAddLink: (e)->
      e.preventDefault()
      link = new AlumNet.Entities.Link
      link.urlRoot = AlumNet.api_endpoint + "/companies/#{@model.id}/links"
      modal = new About.LinkModal
        model: link
        parentView: @
      $('#js-modal-link-container').html(modal.render().el)