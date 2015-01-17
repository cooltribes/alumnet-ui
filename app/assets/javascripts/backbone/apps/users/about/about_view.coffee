@AlumNet.module 'UsersApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

  class About.View extends Marionette.LayoutView
    template: 'users/about/templates/about'

    regions:
      skills: "#skills-list"
      languages: "#languages-list"
      contacts: "#contacts-list"

    templateHelpers: ->
      model = @model
      console.log model
      
      getBorn: ->
        model.getBornAll()        
      
      getLocation: ->
        model.getCurrentLocation()        
      
      getEmail: ->
        model.getEmail()        
      
      getPhone: ->
        model.getPhone()

  
  #For skills
  class About.Skill extends Marionette.ItemView
    template: 'users/about/templates/_skill'
    tagName: "li"

  class About.SkillsView extends Marionette.CollectionView
    # template: 'users/about/templates/skills'
    childView: About.Skill
    # childViewContainer: "#list"

  #For languages
  class About.Language extends Marionette.ItemView
    template: 'users/about/templates/_language'
    tagName: "li"

  class About.LanguagesView extends Marionette.CollectionView
    # template: 'users/about/templates/skills'
    childView: About.Language
    # childViewContainer: "#list"

  #For contact info
  class About.Contact extends Marionette.ItemView
    template: 'users/about/templates/_contact'
    tagName: "li"

  class About.ContactsView extends Marionette.CollectionView
    childView: About.Contact

  