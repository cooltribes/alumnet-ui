@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->

  class Main.FormExperience extends Marionette.ItemView
    template: "registration/experience/templates/aiesecExperience"

    tagName: 'form'

    ui:
      'btnRmv': '.js-rmvRow'
      'cancelEdit': '.js-cancelEdit'
      'btnSave': '.js-saveItem'
      "selectType": "[name=aiesec_experience]"
      "selectRegions": "[name=region_id]"
      "selectCountries": "[name=country_id]"
      "selectCities": "[name=city_id]"
      "selectComitees": "[name=committee_id]"


    events:
      "click .js-rmvRow": "removeItem"
      "click @ui.btnRmv": "removeExperience"
      "click @ui.cancelEdit": "cancelEdit"
      "click @ui.btnSave": "saveExperience"
      "change @ui.selectCountries": "setCitiesAndCommittees"
      "change @ui.selectType": "setCountries"


    initialize: (options)->
      document.title = " AlumNet - registration"
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
          $el.focus()

      @inProfile = options.inProfile ? false

      @model.decodeDates()


    templateHelpers: ->
      model = @model
      month = @MonthType
      inProfile: @inProfile
      months: AlumNet.months
      isEditing: @model.isEditing

      currentYear: new Date().getFullYear()

      selected: (val)->
        if model.get("aiesec_experience") == val then "selected='selected'" else ""

      firstYear: ()->
        born = AlumNet.current_user.profile.get("born")
        parseInt(born.year) + 15

      seniorities:()->
        seniorities = new AlumNet.Utilities.Seniorities
        seniorities.fetch()
        seniorities.results

    onRender: ->
      @cleanAllSelects()

      dataCountries = if @model.get('exp_type') == 0 || @model.get('exp_type') == 1
        CountryAiesecList.toSelect2()
      else
        CountryList.toSelect2()

      # dataRegions = RegionList.toSelect2()

      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: dataCountries

      @ui.selectCountries.select2('val', @model.get("country_id"), true)
      if @model.get('exp_type') == 0 && @model.get("aiesec_experience")
        @setAllCountries(@model.get("aiesec_experience"))


    setCountries: (e)->
      @cleanAllSelects()
      type = $(e.currentTarget).val()
      @setAllCountries type

    setAllCountries: (type)->
      if type == "Local" || type == "National"
        dataCountries = AlumNet.request('get:filtered:countries', type)
      else if type == "International"
        dataCountries = CountryList.toSelect2()
        internationalCommittees = AlumNet.request('get:committees:international')
        @ui.selectComitees.select2
          placeholder: "Select a Committee"
          data: internationalCommittees

      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: dataCountries

      if @model.get("country")
        @ui.selectCountries.select2('val', @model.get("country").id, true)
      else
        @ui.selectCountries.select2('val','')

      if @model.get("committee_id")
        @ui.selectComitees.select2('val', @model.get("committee_id"), true)
      else
        @ui.selectComitees.select2('val','')

      if @model.get("city")
        # @ui.selectCities.select2('val', @model.get("city").id)
      else
        @ui.selectCities.select2('val','')

    cleanAllSelects:(e)->
      @ui.selectCities.select2
        placeholder: "Select a City"
        data: []

      @ui.selectComitees.select2
        placeholder: "Select a Committee"
        data: []

      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: []

    setCitiesAndCommittees: (e)->
      aiesecExp = @ui.selectType.val()
      unless aiesecExp == "International"
        @ui.selectComitees.select2(@optionsForCommittee(e.val, aiesecExp))
      cities_url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      @ui.selectCities.select2(@optionsForSelect2(cities_url, 'City'))

    optionsForSelect2: (url, placeholder)->
      city = @model.get('city')
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
      initSelection: (element, callback)->
        callback(city) if city

    optionsForCommittee: (country_id, aiesecExp)->
      query = { q: { committee_type_eq: aiesecExp } }
      committees = AlumNet.request('get:committees', country_id, query)
      placeholder: "Select a Committee"
      data: committees

    saveExperience: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize this
      @model.set data
      @trigger "save:experience"


    removeExperience: (e)->
      if confirm("Are you sure you want to delete this experience?")
        @model.destroy()


  class Main.ExperienceList extends Marionette.CompositeView
    template: 'registration/experience/templates/experienceList'
    childView: Main.FormExperience
    childViewContainer: '#exp-list'
    className: 'row'

    ui:
      'btnAdd': '.js-addExp'
      'btnSubmit': '.js-submit'
      'btnSkip': '.js-skip'

    events:
      'click @ui.btnAdd': 'addExperience'
      'click @ui.btnSubmit': 'submitClicked'
      'click @ui.btnSkip': 'skipClicked'
      'click .js-linkedin-import': 'linkedinClicked'


    initialize: (options) ->
      @exp_type = options.exp_type
      @layout = options.layout

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
      exp_type: @exp_type
      title:  =>
        @title
      skipButton: =>
        switch @exp_type
          when 1, 2, 3
            true
          else
            false

    onRender: ->
      $('body,html').animate({scrollTop: 20}, 600);

    addExperience: (e)->
      newExperience = new AlumNet.Entities.Experience
        exp_type: @exp_type
      @collection.add(newExperience)

    skipClicked: (e)->
      e.preventDefault()
      @trigger('form:skip', @model)

    saveData: ()->
      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data

      validCollection = @collection.length > 0 #Is valid only when collection has items
      experiencesAtributtes = []

      @collection.each (model)->
        if model.isValid(true)
          model.formatDates()
        else
          validCollection = false

      if validCollection
        @collection.each (model)->
          model.save
            wait: true

        @layout.goToNext()

    saveStepData: (step, indexStep)->
      #retrieve each itemView data

      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data

      validCollection = @collection.length > 0 #Is valid only when collection has items
      experiencesAtributtes = []

      @collection.each (model)->
        if model.isValid(true)
          model.formatDates()
        else
          validCollection = false

      if validCollection
        @collection.each (model)->
          model.save
            wait: true

        profile = AlumNet.current_user.profile
        stepActual = profile.get("register_step")
        if stepActual == "aiesec_experiences"
          Backbone.ajax
            url: AlumNet.api_endpoint + "/me/registration"
            method: "put"
            async: false
            success: (data)->
              stepActual = data.current_step
            error: (data)->
              $.growl.error { message: data.status }
          profile.set("register_step", stepActual)
        @layout.navigateStep(step, indexStep)


    linkedinClicked: (e)->
      if gon.linkedin_profile && gon.linkedin_profile.experiences.length > 0 && @exp_type == 3
        e.preventDefault()
        collection = @collection
        _.each gon.linkedin_profile.experiences, (elem, index, list)->
          contact = collection.findWhere({name: elem.name, organization_name: elem.organization_name})
          unless contact
            collection.add new AlumNet.Entities.ProfileContact elem

