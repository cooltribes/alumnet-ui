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
        
      getLocation: ->
        model.getLocation()

      getOrganization: ->
        model.getOrganization()


  class About.Experiences extends Marionette.CollectionView
    childView: About.Experience    
  

   