@AlumNet.module 'UsersApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.LayoutView
    template: 'users/about/templates/about'

    regions:
      profile: "#profile-info"
      skills: "#skills-list"
      languages: "#languages-list"
      contacts: "#contacts-list"
      experiences: "#experiences-list"

    ui:
      "addSkill": ".js-addSkill"
      "addLanguage": ".js-addLanguage"

    events:
      "click @ui.addSkill": "addSkill"
      "click @ui.addLanguage": "addLanguage"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    addSkill: (e)->
      console.log "skill"
      modal = new About.Modal
        view: @skills.currentView
        type: 0
      $('#js-modal-container').html(modal.render().el)
    
    addLanguage: (e)->
      modal = new About.Modal
        view: @languages.currentView
        type: 1
      $('#js-modal-container').html(modal.render().el)



  class About.Modal extends Backbone.Modal
    # template: 'users/about/templates/_skillsModal'          
    getTemplate: ->
      switch @type
        when 0
          'users/about/templates/_skillsModal'
        when 1
          'users/about/templates/_languagesModal'

    cancelEl: '#js-close-btn'
    submitEl: '#js-save'
    keyControl: false

    ui:
      'skillInput': "#skills-input"

    initialize: (options)->
      @view = options.view
      #Types of modal (0-Skill, 1-Lang)      
      @type = options.type

    onRender: ->
      switch @type
        when 0
          skillsList = new AlumNet.Entities.Skills
          skillsList.fetch
            success: =>
              @fillSkills(skillsList)

        when 1
          slideItem = $("#slider", @el)
          levelTextItem = slideItem.next("#level")          
          levelValue = levelTextItem.next()
          initialValue = 3
          textLevel =
                1: "Elementary"
                2: "Limited working"
                3: "Professional working"
                4: "Full professional"
                5: "Native or Bilingual"

          levelTextItem.text(textLevel[initialValue])
          levelValue.val(initialValue)
          slideItem.slider
            min: 1
            max: 5
            value: initialValue
            slide: (event, ui) ->
              levelTextItem.text(textLevel[ui.value])
              levelValue.val(ui.value)

          #Render the list of languages
          dropdown = $("[name=language_id]", $(@el))
          content = AlumNet.request("languages:html")
          dropdown.html(content)
    
    beforeSubmit: ()->
      switch @type
        when 0  
          data = Backbone.Syphon.serialize this
          if !data.skills
            element = this.$("[name=skills]")
            group = element.closest('.form-group')
            group.addClass('has-error')
            false
    
        when 1
          data = Backbone.Syphon.serialize this          
          if !data.language_id
            element = this.$("[name=language_id]")
            group = element.closest('.form-group')
            group.addClass('has-error') 
            false    

    submit: ()->  
      switch @type
        when 0  
          data = Backbone.Syphon.serialize this
          if data.skills
            data = data.skills.split(',')    
            @view.trigger "submit", data
    
        when 1
          data = Backbone.Syphon.serialize this          
          @view.trigger "submit", data

    fillSkills: (collection)->
      skills = _.pluck(collection.models, 'attributes');
      listOfNames = _.pluck(skills, 'name');
      $("#skills-input",@$el).select2
        tags: listOfNames
        multiple: true
        tokenSeparators: [',', ', '],
        dropdownAutoWidth: true,     


  class About.Profile extends Marionette.ItemView
    template: 'users/about/templates/_profile'

    templateHelpers: ->
      model = @model
      
      getBorn: ->
        model.getBornComplete()        
      
      getLocation: ->
        model.getCurrentLocation()        
      
      getEmail: ->
        model.getEmail()        
      
      getPhone: ->
        if model.phone then model.phone.get "info" else "No Phone"

      canShowPhone: ->      
        if model.phone?    
          friend = model.get "friendship_status"
          model.phone.canShow(friend)  
        else
          false  
      
      canShowEmail: ->    
        if model.email_contact?    
          friend = model.get "friendship_status"
          model.email_contact.canShow(friend) 
        else
          false  
        
    modelEvents:
      "add:phone:email": "modelChange"
    
    # onRender: ->
    #   $('#aboutUseraffix').affix({
    #     offset: {
    #       top: 100,
    #       bottom:150,
    #     }
    #   })

    modelChange: ->
      @render() 

  #For all collection views
  class About.Empty extends Marionette.ItemView
    template: 'users/about/templates/_empty'
    
    initialize: (options)->
      @message = options.message

    templateHelpers: ->
      message: @message 

  #For skills
  class About.Skill extends Marionette.ItemView
    template: 'users/about/templates/_skill'
    tagName: "li"

    events:
      "click .js-rmvRow": "removeItem"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    removeItem: (e)->
      if confirm("Are you sure you want to delete this item from your profile ?")
        @model.destroy()


  class About.SkillsView extends Marionette.CollectionView
    childView: About.Skill   
    childViewOptions: ->
      userCanEdit: @userCanEdit      

    initialize: (options)->
      @userCanEdit = options.userCanEdit      

  #For languages
  class About.Language extends Marionette.ItemView
    template: 'users/about/templates/_language'
    tagName: "li"

    events:
      "click .js-rmvRow": "removeItem"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    removeItem: (e)->
      if confirm("Are you sure you want to delete this item from your profile ?")
        @model.destroy()

  class About.LanguagesView extends Marionette.CollectionView
    childView: About.Language  
    childViewOptions: ->
      userCanEdit: @userCanEdit      

    initialize: (options)->
      @userCanEdit = options.userCanEdit
    

  #For contact info
  class About.Contact extends Marionette.ItemView
    template: 'users/about/templates/_contact'
    tagName: "li"
  
  class About.ContactsView extends Marionette.CollectionView
    childView: About.Contact

    emptyView: About.Empty
    emptyViewOptions: 
      message: "No contact info"

  #For Experiences
  class About.Experience extends Marionette.ItemView
    template: 'users/about/templates/_experience'
    tagName: "div"

    templateHelpers: ->
      model = @model

      diffType: ->
        prev = model.collection.at(model.collection.indexOf(model) - 1)
        if prev?          
          prev.get("exp_type") != model.get("exp_type")
        else    
          true

      experienceType: ->
        model.getExperienceType()
      
      experienceId: ->
        model.getExperienceId()
        
      getLocation: ->
        model.getLocation()

      getOrganization: ->
        model.getOrganization()
      
      getEndDate: ->
        model.getEndDate()


  class About.Experiences extends Marionette.CollectionView
    childView: About.Experience    
  

   