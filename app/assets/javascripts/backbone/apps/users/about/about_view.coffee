@AlumNet.module 'UsersApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.LayoutView
    template: 'users/about/templates/about'

    regions:
      profile: "#profile-info"
      skills: "#skills-list"
      languages: "#languages-list"
      contacts: "#contacts-list"
      experiences: "#experiences-list"



  class About.Profile extends Marionette.ItemView
    template: 'users/about/templates/_profile'

    templateHelpers: ->
      model = @model
      
      getBorn: ->
        model.getBornAll()        
      
      getLocation: ->
        model.getCurrentLocation()        
      
      getEmail: ->
        model.getEmail()        
      
      getPhone: ->
        if model.phone then model.phone.get "info" else "No Phone"
        
    modelEvents:
      "add:phone": "modelChange"
    
    modelChange: ->
      # console.log this
      @render() 

  
  #For skills
  class About.Skill extends Marionette.ItemView
    template: 'users/about/templates/_skill'
    tagName: "li"

  class About.SkillsView extends Marionette.CollectionView
    childView: About.Skill    
    

  #For languages
  class About.Language extends Marionette.ItemView
    template: 'users/about/templates/_language'
    tagName: "li"

  class About.LanguagesView extends Marionette.CollectionView
    childView: About.Language   
    

  #For contact info
  class About.Contact extends Marionette.ItemView
    template: 'users/about/templates/_contact'
    tagName: "li"

  class About.ContactsView extends Marionette.CollectionView
    childView: About.Contact

  #For Experiences
  class About.Experience extends Marionette.ItemView
    template: 'users/about/templates/_experience'
    tagName: "li"

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
        


  class About.Experiences extends Marionette.CollectionView
    childView: About.Experience    

  