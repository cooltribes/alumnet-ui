@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Experience.FormAiesec extends Marionette.ItemView
    # template: 'registration/experience/templates/aiesecExperience'

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
      "country": "[name=country_id]"   
      "city": "[name=city_id]"   
      "lcomitee": "[name=local_comitee]"   
      "addMonth": ".js-addMonth"   
     
    events:
      "click @ui.btnRmv": "removeExperience"
      "change @ui.country": "changeDepencencies"       
      "click @ui.addMonth": "addMonth"       


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


    onShow: ->           
      dropdown = @ui.country
      countries = new AlumNet.Entities.Countries
      
      countries.fetch 
        success: (collection, response, options)->
          fillCountries(collection, dropdown)

      #Add select2 to cities and committees
      @ui.city.add(@ui.lcomitee).select2()


    addMonth: (e) ->
      $(e.target).addClass("hidden")
      $(e.target).prev().removeClass("hidden")

    changeDepencencies: (e) ->
      countryId = @ui.country.val()         
      dropdownCities = @ui.city #Add localcomitee
      dropdownCom = @ui.lcomitee


      cities = AlumNet.request("cities:get_cities", countryId)
      cities.fetch 
        success: (collection, response, options)->
          fillCities(collection, dropdownCities)


      committees = AlumNet.request("cities:get_committees", countryId)
      committees.fetch 
        success: (collection, response, options)->
          fillCommittees(collection, dropdownCom)

     
    fillCountries = (countries, dropdowns)->  
      content = AlumNet.request("countries:html", countries)
      dropdowns.html(content)  


    fillCities = (cities, dropdown)->  
      content = AlumNet.request("cities:html", cities)
      dropdown.html(content)

    fillCommittees = (collection, dropdown)->  
      content = AlumNet.request("committees:html", collection)
      dropdown.html(content)
        
      
    removeExperience: (e)->
      @model.destroy()

  
  class Experience.ExperienceList extends Marionette.CompositeView
    template: 'registration/experience/templates/experienceList'    
    childView: Experience.FormAiesec    
    childViewContainer: '#exp-list'
    className: 'row'
          
    ui:
      'btnAdd': '.js-addExp'
      'btnSubmit': '.js-submit'
    events:
      "click @ui.btnAdd": "addExperience"
      "click @ui.btnSubmit": "submitClicked"

    initialize: (options) ->
      @title = options.title           


    templateHelpers: ->
      titleNew = @title
      title:  =>
        @title
      
    addExperience: (e)->
      newExperience = new AlumNet.Entities.Experience
        exp_type: 0
      @collection.add(newExperience)


    submitClicked: (e)->
      e.preventDefault()
      
      experiences = new Array()
      
      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
        
      this.trigger("form:submit", @model)

    
