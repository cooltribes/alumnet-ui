@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->

  class Main.FormLanguage extends Marionette.ItemView
    template: "registration/skills/templates/form"
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
      'btnRmv': '.js-rmvRow'
    events:
      "click @ui.btnRmv": "removeItem"

    removeItem: (e)->
      @model.destroy()

    onRender: ->
      #Render the slider
      view = @
      slideItem = $("#slider", @el)
      levelTextItem = slideItem.next("#level")
      model = @model

      textLevel =
            1: "Elementary"
            2: "Limited working"
            3: "Professional working"
            4: "Full professional"
            5: "Native or Bilingual"

      levelTextItem.text(textLevel[@model.get("level")])

      slideItem.slider
        min: 1
        max: 5
        value: parseInt( @model.get("level"), 10 )
        slide: (event, ui) ->
          levelTextItem.text(textLevel[ui.value])
          model.set("level", ui.value)
          $(this).find('#bar').removeClass("bar__1")
          $(this).find('#bar').removeClass("bar__2")
          $(this).find('#bar').removeClass("bar__3")
          $(this).find('#bar').removeClass("bar__4")
          $(this).find('#bar').removeClass("bar__5")
          $(this).find('#bar').addClass("bar__"+ui.value)
          
      #Render the list of languages
      dropdown = $("[name=language_id]", $(@el))
      content = AlumNet.request("languages:html", @model.get("name"), @model.get("language_id") ? null)
      dropdown.html(content)

  class Main.LanguageList extends Marionette.CompositeView
    template: 'registration/skills/templates/skills'
    childView: Main.FormLanguage
    childViewContainer: '#lan-list'
    className: 'row'

    initialize: (options)->
      document.title = " AlumNet - Registration"
      @linkedin_skills = options.linkedin_skills
      @layout = options.layout  
      @skills_collection = new AlumNet.Entities.Skills
      @user_skills = new AlumNet.Entities.Skills
      @user_skills.url = AlumNet.api_endpoint + '/profiles/' + @model.id + "/skills"
        

    templateHelpers: ->
      linkedin_skills: @linkedin_skills.join(", ")

    ui:
      'btnAdd': '.js-addRow'
      'skills': '#skills-input'

    events:
      'click @ui.btnAdd': 'addRow'
      'click .js-linkedin-import': 'linkedinClicked'

    onRender: ->
      @skills_collection.fetch
        wait: true
        success: (collection)=>
          @fillSkills(collection)
          #Fetching the actually user skills for populating the field
          @user_skills.fetch
            wait: true
            success: (collection)=>
              skills = _.pluck(collection.models, 'attributes')
              listOfNames = _.pluck(skills, 'name')              
              @ui.skills.select2 "val", listOfNames

      $('body,html').animate({scrollTop: 0}, 600);

    fillSkills: (collection)->
      skills = _.pluck(collection.models, 'attributes')
      listOfNames = _.pluck(skills, 'name')
      @ui.skills.select2
        tags: listOfNames
        multiple: true
        tokenSeparators: [',', ', ']
        dropdownAutoWidth: true


    addRow: (e)->
      newRow = new AlumNet.Entities.ProfileLanguage
      @collection.add(newRow)


    saveData: ()->
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data

      skillsData = Backbone.Syphon.serialize this
      skillsData = skillsData.skills.split(',')

      if skillsData.length > 2
        $el = @$("[name^=skills]")
        $group = $el.closest('.form-group')
        $group.removeClass('has-error')
        $group.find('.help-block').html("").addClass('hidden')
        valid_skills = true

      else
        $el = @$("[name^=skills]")
        $group = $el.closest('.form-group')
        $group.addClass('has-error')
        $group.find('.help-block').html("You have to set at least 3 skills").removeClass('hidden')
        valid_skills = false

      #every model in the collection of languages is valid
      valid_languages = true

      _.forEach @collection.models, (model, index, list)->
        if !(validity = model.isValid(true))
          valid_languages = validity
      
      if valid_languages && valid_skills
        @saveSkillsAndLanguages(skillsData)

            
    saveSkillsAndLanguages: (skillsData)->
      #SKILLS------------      
      #Send a POST for creating skills in bulk way 
      @user_skills.create
        skill_names: skillsData

      #LANGUAGES------------
      @collection.forEach (el, i, collection)->
        el.save
          wait: true

      @layout.goToNext()

    saveStepData: (step, indexStep)->

      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data

      skillsData = Backbone.Syphon.serialize this
      skillsData = skillsData.skills.split(',')

      if skillsData.length > 2
        $el = @$("[name^=skills]")
        $group = $el.closest('.form-group')
        $group.removeClass('has-error')
        $group.find('.help-block').html("").addClass('hidden')
        valid_skills = true

      else
        $el = @$("[name^=skills]")
        $group = $el.closest('.form-group')
        $group.addClass('has-error')
        $group.find('.help-block').html("You have to set at least 3 skills").removeClass('hidden')
        valid_skills = false

      #every model in the collection of languages is valid
      valid_languages = true

      _.forEach @collection.models, (model, index, list)->
        if !(validity = model.isValid(true))
          valid_languages = validity
      
      if valid_languages && valid_skills

        @saveSkillsAndLanguagesStep(skillsData, step, indexStep)

            
    saveSkillsAndLanguagesStep: (skillsData, step, indexStep)->
   
      #SKILLS------------      
      #Send a POST for creating skills in bulk way 
      @user_skills.create
        skill_names: skillsData

      #LANGUAGES------------
      @collection.forEach (el, i, collection)->
        el.save
          wait: true
      
      profile = AlumNet.current_user.profile
      stepActual = profile.get("register_step")
      if stepActual == "languages_and_skills"
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
      if gon.linkedin_profile && gon.linkedin_profile.skills.length > 0
        e.preventDefault()
        @render()