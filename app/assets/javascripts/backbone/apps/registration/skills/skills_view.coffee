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
      slideItem = $("#slider", @el)
      levelTextItem = slideItem.next("#level")

      textLevel = 
            1: "Basic"
            2: "Basic Intermediate"    
            3: "Intermediate"    
            4: "Intermediate Advanced"    
            5: "Advanced"    

      levelTextItem.text(textLevel[@model.get("level")])

      slideItem.slider
        min: 1
        max: 5
        value: parseInt( @model.get("level"), 10 )
        slide: (event, ui) ->          
          levelTextItem.text(textLevel[ui.value])
          
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
      'skills': '#skills-input'
    events:
      "click @ui.btnAdd": "addRow"
      "click @ui.btnSubmit": "submitClicked"

    onShow: ->
      skillsList = new AlumNet.Entities.Skills
      skillsList.fetch
        success: =>
          @fillSkills(skillsList)

      
    fillSkills: (collection)->
  
      skills = _.pluck(collection.models, 'attributes');
      listOfNames = _.pluck(skills, 'name');
      # console.log this
      @ui.skills.select2
        # tags: []        
        tags: listOfNames        
        multiple: true
        tokenSeparators: [',', ', '],
        dropdownAutoWidth: true,
        # minimumInputLength: 3,
        # ajax:
        #   url: AlumNet.api_endpoint + '/skills'
        #   dataType: 'json'
        #   data: (term)->
        #     q:
        #       m: 'or'
        #       name_cont: term
        #       # profile_last_name_cont: term
        #   results: (data, page) ->
        #     results:
        #       data
        # formatResult: (data)->
        #   data.name
        # formatSelection: (data)->
        #   data.name 


    addRow: (e)->      
      newRow = new AlumNet.Entities.ProfileLanguage        
      @collection.add(newRow)


    submitClicked: (e)->
      e.preventDefault()      
      
      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
      
      skillsData = Backbone.Syphon.serialize this #, 
        # include: "skills"
      skillsData = skillsData.skills.split(',')
        
      this.trigger("form:submit", @model, skillsData)

    
