@AlumNet.module 'RegistrationApp.Skills', (Skills, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Skills.FormLanguage extends Marionette.ItemView
    # template: 'registration/experience/templates/aiesecExperience'

    template: "registration/skills/templates/form"

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
      "click @ui.btnRmv": "removeItem"

      
    removeItem: (e)->
      @model.destroy()

    onShow: ->      
      #Render the slider
      $("#slider", @el).slider
        min: 1
        max: 6
        value: parseInt( @model.get("level"), 10 )

      #Render the list of languages
      dropdown = $("[name=language_id]", $(@el))  
      
      #list of languages from api
      languages = new AlumNet.Entities.Languages
      
      languages.fetch 
        success: (collection, response, options)->          
          fillLaguages(collection, dropdown)

    
    fillLaguages = (collection, dropdown)->        
      content = AlumNet.request("languages:html", collection)
      dropdown.html(content)  
        



  
  class Skills.LanguageList extends Marionette.CompositeView
    template: 'registration/skills/templates/skills'    
    childView: Skills.FormLanguage    
    # getChildView: (item) -> 
    #   if item.get('exp_type') == 0
    #     Experience.FormAiesec           
    #   else if item.get('exp_type') == 1 
    #     Experience.FormAlumni
    childViewContainer: '#lan-list'
    className: 'row'
          
    ui:
      'btnAdd': '.js-addRow'
      'btnSubmit': '.js-submit'
    events:
      "click @ui.btnAdd": "addRow"
      "click @ui.btnSubmit": "submitClicked"



    addRow: (e)->      
      newRow = new AlumNet.Entities.ProfileLanguage        
      @collection.add(newRow)


    submitClicked: (e)->
      e.preventDefault()      
      
      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
        
      this.trigger("form:submit", @model)

    
