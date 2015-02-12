@AlumNet.module 'UsersApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      user = AlumNet.request("user:find", id)
      user.on 'find:success', (response, options)=>
        
        layout = AlumNet.request("user:layout", user, 1)
        header = AlumNet.request("user:header", user)
                        
        profileId = user.profile.id

        #get the skills of the user
        skills = new AlumNet.Entities.Skills
        skills.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/skills"
        skills.fetch
          error: (collection, response, options) ->
          success: (collection, response, options) ->

        #get the languages of the user
        languages = new AlumNet.Entities.Languages
        languages.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/language_levels"
        languages.fetch
          error: (collection, response, options) ->
          success: (collection, response, options) ->

        #get the contacts of the user
        phones = []
        emails = []
        contacts = new AlumNet.Entities.ProfileContactsCollection        
        contacts.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/contact_infos"
        contacts.fetch
          error: (collection, response, options) ->
                      
          success: (collection, response, options) ->
            #Adding the phone to the profile info
            phones = collection.where 
              contact_type: 1

            user.phone = phones[0]  

            emails = collection.where 
              contact_type: 0

            user.email_contact = emails[0]  
            user.trigger("add:phone:email")      

            #Get all except the phone and email
            newCollection = collection.filter (model)->              
              a = model.get("contact_type") != 0 && model.get("contact_type") != 1
              b = model.canShow(user.get "friendship_status")
              a && b  
            
            collection.reset(newCollection)


        expCollection = new AlumNet.Entities.ExperienceCollection        
        expCollection.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/experiences"
        expCollection.comparator = "exp_type"
        expCollection.fetch()

        #Edit Options - permissions    
        userCanEdit = AlumNet.current_user.isAlumnetAdmin() || user.isCurrentUser()               

        body = new About.View
          model: user
          userCanEdit: userCanEdit
          
        profileView = new About.Profile
          model: user
          userCanEdit: userCanEdit          

        skillsView = new About.SkillsView
          collection: skills
          userCanEdit: userCanEdit

        languagesView = new About.LanguagesView
          collection: languages
          userCanEdit: userCanEdit

        contactsView = new About.ContactsView
          collection: contacts
          userCanEdit: userCanEdit          

        aiesecView = new About.Experiences
          collection: expCollection
          
        @setEditActions(skillsView, 0)  
        @setEditActions(languagesView, 1)  
        @setEditActions(contactsView, 2)         
        @setEditActions(profileView, 3)         


        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)

        #Show each region of the about page
        body.profile.show(profileView)
        body.skills.show(skillsView)
        body.languages.show(languagesView)
        body.contacts.show(contactsView)
        body.experiences.show(aiesecView)     

        AlumNet.execute('render:users:submenu')


      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
  
    #set the action when modal is submitted for each info
    #0-skills, 1-languages,
    setEditActions: (view, type)->

      switch type
        when 0  #skills    
          view.on "submit", (data)->
            #Add each skill to the collection
            collection = view.collection  

            _.each data, (el)->
              collection.create({name: el})

        when 1, 2      #languages, contact infos
          view.on "submit", (data)->
            #Add the language and level to the collection
            view.collection.create(data, {wait: true})
        
        when 3  #name
          view.on "submit:name", ()->            
            @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
            @model.profile.save 
              "first_name": @model.profile.get "first_name"
              "last_name": @model.profile.get "last_name",
            ,
              wait: true
              success: ()=>
                @model.fetch()            
        
          view.on "submit:born", ()->  
            @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
            @model.profile.save 
              "birth_country_id": @model.profile.get "birth_country_id"
              "birth_city_id": @model.profile.get "birth_city_id",
            ,
              wait: true
              success: ()=>
                # @render()
                AlumNet.trigger "user:about", @model.id
                # model = @model
                # @model.profile.fetch
                #   success: ->
                #     model.trigger("change")

          view.on "submit:residence", ()->  
            @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
            @model.profile.save 
              "residence_country_id": @model.profile.get "residence_country_id"
              "residence_city_id": @model.profile.get "residence_city_id",
            ,
              wait: true
              success: ()=>
                # @render()
                AlumNet.trigger "user:about", @model.id
                # model = @model
                # @model.profile.fetch
                #   success: ->
                #     model.trigger("change")

            
            
          
          
              
        