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
      "addContact": ".js-addContact"
      "modalCont": "#js-modal-container"

    events:
      "click @ui.addSkill": "addSkill"
      "click @ui.addLanguage": "addLanguage"
      "click @ui.addContact": "addContact"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    addSkill: (e)->
      e.preventDefault()
      modal = new About.Modal
        view: @skills.currentView
        type: 0
      @ui.modalCont.html(modal.render().el)
    
    addLanguage: (e)->
      e.preventDefault()
      modal = new About.Modal
        view: @languages.currentView
        type: 1
      @ui.modalCont.html(modal.render().el)
    
    addContact: (e)->
      e.preventDefault()
      modal = new About.Modal
        view: @contacts.currentView
        type: 2
      @ui.modalCont.html(modal.render().el)

    # onRender: ->
    #   $('#aboutUseraffix').affix({
    #     offset: {
    #       top: 100,
    #       bottom:150,
    #     }
    #   })

  class About.Modal extends Backbone.Modal
    getTemplate: ->
      switch @type
        when 0
          'users/about/templates/_skillsModal'
        when 1
          'users/about/templates/_languagesModal'
        when 2
          'users/about/templates/_contactsModal'


    cancelEl: '#js-close-btn'
    submitEl: '#js-save'
    keyControl: false

    initialize: (options)->
      @view = options.view
      #Types of modal (0-Skill, 1-Lang, 2-contc)      
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
      #Validations
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

        when 2
          data = Backbone.Syphon.serialize this 
          if !data.contact_type
            element = this.$("[name=contact_type]")
            group = element.closest('.form-group')
            group.addClass('has-error') 
            return false    

          if !data.info
            element = this.$("[name=info]")
            group = element.closest('.form-group')
            group.addClass('has-error') 
            return false    

    submit: ()->  
      switch @type
        when 0  
          data = Backbone.Syphon.serialize this
          if data.skills
            data = data.skills.split(',')    
            @view.trigger "submit", data
    
        when 1, 2
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


  class About.ProfileModal extends Backbone.Modal
    getTemplate: ->
      switch @type
        when 0
          'users/about/templates/_nameModal'
        when 1
          'users/about/templates/_bornModal'
        when 2
          'users/about/templates/_residenceModal'
        when 3
          'users/about/templates/_pictureModal'

    cancelEl: '#js-close-btn'
    submitEl: '#js-save'
    keyControl: false
    events:      
      'change #js-countries': 'setBirthCities'
      'change #profile-avatar': 'previewImage'      

    initialize: (options)->
      @view = options.view
      #Types of modal (0-name)
      @type = options.type

      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    onRender: ->
      # switch @type
      #   when 0 
      # limit_date = moment().subtract(20, 'years').format("YYYY-MM-DD")
      # @$(".js-date-born").Zebra_DatePicker
      #   show_icon: false
      #   show_select_today: false
      #   view: 'years'
      #   default_position: 'below'
      #   direction: ['1910-01-01', limit_date]
       
      @$("#js-cities").select2
        placeholder: "Select a City"
        data: []

      data = CountryList.toSelect2()

      @$("#js-countries").select2
        placeholder: "Select a Country"
        data: data    

      # @ui.selectBirthCountries.select2('val', @model.get('birth_country_id'))        

          
    beforeSubmit: ()->
      data = Backbone.Syphon.serialize this
      if @type != 3
        @model.set(data)
        @model.validate()

      #Validations
      switch @type
        when 0            
          @model.isValid(["first_name", "last_name"])
        
        when 1  
          @model.isValid(["birth_country_id", "birth_city_id"])

        when 2
          @model.isValid(["residence_country_id", "residence_city_id"])


    submit: ()->  
      switch @type
        when 0  
          @view.trigger "submit:name"         
        when 1
          @view.trigger "submit:born"         
        when 2
          @view.trigger "submit:residence" 
        when 3
          data = Backbone.Syphon.serialize this
          if data.avatar != ""          
            formData = new FormData()
            console.log formData
            file = @$('#profile-avatar')
            formData.append('avatar', file[0].files[0])            
            console.log formData
            @view.trigger "submit:avatar", formData
    
    optionsForSelectCities: (url)->
      placeholder: "Select a City"
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

    setBirthCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      @$("#js-cities").select2(@optionsForSelectCities(url))  

    previewImage: (e)->
      input = @$('#profile-avatar')
      preview = @$('#preview-avatar')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])  

  class About.Profile extends Marionette.ItemView
    template: 'users/about/templates/_profile'

    ui:
      "modalCont": "#js-profile-modal-container"     
      "editName": "#js-editName"    
      "editBorn": "#js-editBorn"    
      "editResidence": "#js-editResidence"    
      

    events:
      "click @ui.editName": "editName"
      "click @ui.editBorn": "editBorn"
      "click @ui.editResidence": "editResidence"

    initialize: (options)->      
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      model = @model
      
      userCanEdit: @userCanEdit  

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
      "add:phone:email change": "modelChange"

    modelChange: ->
      @render() 

    editName: (e)-> 
      e.preventDefault()
      modal = new About.ProfileModal
        view: this
        type: 0
        model: @model.profile

      @ui.modalCont.html(modal.render().el)
    
    editBorn: (e)-> 
      e.preventDefault()
      modal = new About.ProfileModal
        view: this
        type: 1
        model: @model.profile

      @ui.modalCont.html(modal.render().el)

    editResidence: (e)->
      e.preventDefault()
      modal = new About.ProfileModal
        view: this
        type: 2
        model: @model.profile

      @ui.modalCont.html(modal.render().el)


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

    events:
      "click .js-rmvRow": "removeItem"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    removeItem: (e)->
      if confirm("Are you sure you want to delete this item from your profile ?")
        @model.destroy()
  
  class About.ContactsView extends Marionette.CollectionView
    childView: About.Contact    
    emptyView: About.Empty
    emptyViewOptions: 
      message: "No contact info"
    childViewOptions: ->
      userCanEdit: @userCanEdit      

    initialize: (options)->
      @userCanEdit = options.userCanEdit  

  #For Experiences
  class About.Experience extends Marionette.ItemView
    template: 'users/about/templates/_experience'
    tagName: "div"

    # bindings:
    #   ".js-title": 
    #     observe: "name"

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
  

   