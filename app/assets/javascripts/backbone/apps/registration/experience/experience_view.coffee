@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Experience.FormAiesec extends Marionette.ItemView
    # template: 'registration/experience/templates/aiesecExperience'

    getTemplate: -> 
      if @model.get('exp_type') == 0
        "registration/experience/templates/aiesecExperience"
      else if @model.get('exp_type') == 1 
        "registration/experience/templates/alumniExperience"

    # className: 'row'
    # tagName: 'fieldset'
    tagName: 'form'

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          # console.log "bad"
          # console.log view
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')
    ui:
      'btnRmv': '.js-rmvRow'
     
    events:
      "click @ui.btnRmv": "removeExperience"

      
    removeExperience: (e)->
      @model.destroy()

  
  class Experience.ExperienceList extends Marionette.CompositeView
    template: 'registration/experience/templates/experienceList'    
    childView: Experience.FormAiesec    
    # getChildView: (item) -> 
    #   if item.get('exp_type') == 0
    #     Experience.FormAiesec           
    #   else if item.get('exp_type') == 1 
    #     Experience.FormAlumni
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
    # serializeData: ->
      titleNew = @title
      title:  =>
        @title
      
        # console.log this.view.title
        # console.log @foo



    addExperience: (e)->
      newExperience = new AlumNet.Entities.Experience
        exp_type: 0
      @collection.add(newExperience)


    submitClicked: (e)->
      e.preventDefault()
      
      # formData = new FormData()
      experiences = new Array()

      # console.log @children.length
      
      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
        
      this.trigger("form:submit", @model)

    
