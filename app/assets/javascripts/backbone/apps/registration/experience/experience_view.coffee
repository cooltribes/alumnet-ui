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
    ui:
      'btnRmv': '.js-rmvRow'
     
    events:
      "click @ui.btnRmv": "removeExperience"

    onShow: ->
      dropdowns = $("[name=country_id]", $(@el))  
      
      countries = new AlumNet.Entities.Countries
      
      countries.fetch 
        success: (collection, response, options)->
          fillCountries(collection, dropdowns)

    
    fillCountries = (countries, dropdowns)->  
      content = AlumNet.request("countries:html", countries)
      dropdowns.html(content)  

      
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

    
