@AlumNet.module 'Shared.Views.Experiences', (Experiences, @AlumNet, Backbone, Marionette, $, _) ->

  class Experiences.FormExperience extends Marionette.ItemView
    getTemplate: ->
      if @model.get('exp_type') == 0
        "_shared/experiences/templates/aiesecExperience"
      else if @model.get('exp_type') == 1
        "_shared/experiences/templates/alumniExperience"
      else if @model.get('exp_type') == 2
        "_shared/experiences/templates/academicExperience"
      else if @model.get('exp_type') == 3
        "_shared/experiences/templates/professionalExperience"

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
      "selectCompany": "[name=company_id]"
      "inputCompany": "#organization_name"

    triggers:
      "click @ui.cancelEdit": "cancelEdit"

    events:
      "click .js-rmvRow": "removeItem"
      "click @ui.btnRmv": "removeExperience"
      "click @ui.btnSave": "saveExperience"
      "change @ui.selectCountries": "setCitiesAndCommittees"
      "change @ui.selectType": "setCountries"


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
          $el.focus()

      @inProfile = options.inProfile ? false

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
      view = @
      companies = new Bloodhound
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
        queryTokenizer: Bloodhound.tokenizers.whitespace
        prefetch: AlumNet.api_endpoint + '/companies/'
        remote:
          wildcard: '%query'
          url: AlumNet.api_endpoint + '/companies/?q[name_cont]=%query'

      @ui.inputCompany.typeahead null,
        name: 'companies'
        display: 'name'
        source: companies

      @ui.inputCompany.bind 'typeahead:select', (e, suggestion)->
        view.model.set(company_id: suggestion.id)
        # console.log view.model.get("company_id")

      @cleanAllSelects()
      # if @model.get('exp_type') == 0
      #   @setAllCountries(@model.get "aiesec_experience")

      dataCountries = if @model.get('exp_type') == 0 || @model.get('exp_type') == 1
        CountryAiesecList.toSelect2()
      else
        CountryList.toSelect2()

      @ui.selectCountries.select2
        placeholder: "Select a Country"
        data: dataCountries
      @ui.selectCountries.select2('val', @model.get("country").id, true)

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

      @ui.selectCountries.select2('val','')
      @ui.selectComitees.select2('val','')
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
      console.log city       
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
