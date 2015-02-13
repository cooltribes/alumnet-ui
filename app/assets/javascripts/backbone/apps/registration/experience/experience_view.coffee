@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->

  class Experience.FormExperience extends Marionette.ItemView
    getTemplate: ->
      if @model.get('exp_type') == 0
        "registration/experience/templates/aiesecExperience"
      else if @model.get('exp_type') == 1
        "registration/experience/templates/alumniExperience"
      else if @model.get('exp_type') == 2
        "registration/experience/templates/academicExperience"
      else if @model.get('exp_type') == 3
        "registration/experience/templates/professionalExperience"

    tagName: 'form'    

    ui:
      'btnRmv': '.js-rmvRow'
      'btnSave': '.js-saveItem'
      "selectRegions": "[name=region_id]"
      "selectCountries": "[name=country_id]"
      "selectCities": "[name=city_id]"
      "selectComitees": "[name=committee_id]"


    events:
      "click @ui.btnRmv": "removeExperience"
      "click @ui.btnSave": "saveExperience"
      "change @ui.selectCountries": "setCitiesAndCommittees"

    initialize: (options)->
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

      @inProfile = options.inProfile ? false      
    
    templateHelpers: ->
      
      inProfile: @inProfile            

      currentYear: new Date().getFullYear()

      firstYear: ()->
        born = AlumNet.current_user.profile.get("born")
        born = new Date(born).getFullYear()
        born + 15
          
    onRender: ->
      @ui.selectCities.select2
        placeholder: "Select a City"
        data: []
        allowClear: true

      @ui.selectComitees.select2
        placeholder: "Select a Committee"
        data: []
        allowClear: true

      dataCountries = CountryList.toSelect2()
      dataRegions = RegionList.toSelect2()

      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: dataCountries
        allowClear: true

      @ui.selectRegions.select2
        placeholder: "Select a Region"
        data: dataRegions
        allowClear: true

      ui = @ui
      @ui.selectCountries.on 'select2-selecting', (e)->
        ui.selectRegions.select2('val', '')

      @ui.selectCountries.on 'select2-removed', (e)->
        console.log "country unselected"

      @ui.selectRegions.on 'select2-selecting', (e)->
        ui.selectCountries.select2('val', '')
        ui.selectCities.select2('val', '')
        ui.selectComitees.select2('val', '')

      @ui.selectRegions.on 'select2-removed', (e)->
        console.log "region unselected"

    setCitiesAndCommittees: (e)->
      cities_url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      committees_url = AlumNet.api_endpoint + '/countries/' + e.val + '/committees'
      @ui.selectCities.select2(@optionsForSelect2(cities_url, 'City'))
      @ui.selectComitees.select2(@optionsForSelect2(committees_url, 'Committee'))

    optionsForSelect2: (url, placeholder)->
      placeholder: "Select a #{placeholder}"
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

    saveExperience: (e)->
      data = Backbone.Syphon.serialize this
      @model.set data
      @trigger "save:experience"

    removeExperience: (e)->
      @model.destroy()


  class Experience.ExperienceList extends Marionette.CompositeView
    template: 'registration/experience/templates/experienceList'
    childView: Experience.FormExperience
    childViewContainer: '#exp-list'
    className: 'row'

    ui:
      'btnAdd': '.js-addExp'
      'btnSubmit': '.js-submit'
      'btnSkip': '.js-skip'

    events:
      "click @ui.btnAdd": "addExperience"
      "click @ui.btnSubmit": "submitClicked"
      "click @ui.btnSkip": "skipClicked"

    initialize: (options) ->     
      @exp_type = options.exp_type

      @title = 'Experience in AIESEC'

      switch @exp_type
        when 1
          @title = 'Experience in AIESEC Alumni'
        when 2
          @title = 'Academic Experience'
        when 3
          @title = 'Professional Experience'
        else
          false

    templateHelpers: ->
      title:  =>
        @title
      skipButton: =>
        switch @exp_type
          when 1, 2, 3
            true
          else
            false

    addExperience: (e)->
      newExperience = new AlumNet.Entities.Experience
        exp_type: @exp_type
      @collection.add(newExperience)

    skipClicked: (e)->
      e.preventDefault()
      @trigger("form:skip", @model)

    submitClicked: (e)->
      e.preventDefault()

      experiences = new Array()

      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data

      @trigger("form:submit", @model)


