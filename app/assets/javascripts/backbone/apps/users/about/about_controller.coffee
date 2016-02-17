@AlumNet.module 'UsersApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      user = AlumNet.request("user:find", id)
      user.on 'find:success', (response, options)=>

        profileId = user.profile.id
        #Edit Options - permissions
        userCanEdit = AlumNet.current_user.isAlumnetAdmin() || user.isCurrentUser()

        layout = AlumNet.request("user:layout", user, 1)
        header = AlumNet.request "user:header", user,
          userCanEdit: userCanEdit

        #get the skills of the user
        skills = new AlumNet.Entities.Skills
        skills.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/skills"
        skills.fetch()

        #get the languages of the user
        languages = new AlumNet.Entities.Languages
        languages.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/language_levels"
        languages.fetch()

        #get the contacts of the user
        phones = []
        emails = []
        contacts = new AlumNet.Entities.ProfileContactsCollection
        contacts.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/contact_infos"
        contacts.fetch
          success: (collection, response, options) ->
            #Adding the phone and the email to the profile info
            phones = collection.where
              contact_type: 1

            if phones.length
              user.phone = phones[0]
              user.phone.urlRoot = contacts.url

            emails = collection.where
              contact_type: 0

            if emails.length
              user.email_contact = emails[0]
              user.email_contact.urlRoot = contacts.url

            user.trigger("add:phone:email")

            #Get all except the phone and email
            newCollection = collection.filter (model)->
              model.get("contact_type") != 0 && model.get("contact_type") != 1

            collection.reset(newCollection)

        expCollection = new AlumNet.Entities.ExperienceCollection

        expCollection.setOrder()

        expCollection.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/experiences"
        expCollection.fetch
          success: (collection)=>
              #only allowed if user can edit
              # if userCanEdit
              collection.addTitles()

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

        experiencesView = new About.Experiences
          collection: expCollection
          userCanEdit: userCanEdit

        @setEditActions skillsView, 0
        @setEditActions languagesView, 1
        @setEditActions contactsView, 2
        @setEditActions profileView, 3
        @setEditActions header, 4
        @setEditActions experiencesView, 5


        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)

        #Show each region of the about page
        body.profile.show(profileView)
        body.skills.show(skillsView)
        body.languages.show(languagesView)
        body.contacts.show(contactsView)
        body.experiences.show(experiencesView)

        #AlumNet.execute('render:users:submenu')

      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

    showProfile: (id)->
      user = AlumNet.request("user:find", id)
      user.on 'find:success', (response, options)=>

        # if user.isCurrentUser()
        #   AlumNet.trigger('show:error', 404)
        #   return

        profileId = user.profile.id
        #Edit Options - permissions
        userCanEdit = false #None of users can edit in this profile view

        # layout = AlumNet.request("user:layout", user, 1)
        # header = AlumNet.request "user:header", user,
          # userCanEdit: userCanEdit

        #get the skills of the user
        skills = new AlumNet.Entities.Skills
        skills.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/skills"
        skills.fetch()

        #get the languages of the user
        languages = new AlumNet.Entities.Languages
        languages.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/language_levels"
        languages.fetch()


        expCollection = new AlumNet.Entities.ExperienceCollection

        expCollection.setOrder()

        expCollection.url = AlumNet.api_endpoint + '/profiles/' + profileId + "/experiences"
        expCollection.fetch
          success: (collection)=>
              #only allowed if user can edit
              # if userCanEdit
              collection.addTitles()

        body = new About.PublicProfile
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
          showLevel: false

        experiencesView = new About.Experiences
          collection: expCollection
          userCanEdit: userCanEdit

        AlumNet.mainRegion.show(body)
        # layout.header.show(header)
        # layout.body.show(body)

        #Show each region of the about page
        body.profile.show(profileView)
        body.skills.show(skillsView)
        body.languages.show(languagesView)
        body.experiences.show(experiencesView)

        #AlumNet.execute('render:users:submenu')

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
            #new way of creating skills in bulk
            collection.create
              skill_names: data
            ,
              success: (model)->
                model.collection.fetch()

        when 1, 2  #languages, contact infos
          view.on "submit", (data)->
            console.log data
            #Add the language and level to the collection
            console.log view.collection
            view.collection.create(data, {wait: true})
            console.log view.collection

        when 3  #profile
          view.on "submit:name", ()->
            @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
            @model.profile.save
              "first_name": @model.profile.get "first_name"
              "last_name": @model.profile.get "last_name",
            ,
              wait: true
              success: ()=>
                @model.profile.url = @model.urlRoot() + @model.id + '/profile'
                @model.fetch()
                #Update current user
                if @model.isCurrentUser()
                  AlumNet.request 'get:current_user',
                    refresh: true
                    success: ->
                      #AlumNet.execute('render:users:submenu', undefined, {reset: true})


          view.on "submit:born", ()->
            @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
            @model.profile.save
              "birth_country_id": @model.profile.get "birth_country_id"
              "birth_city_id": @model.profile.get "birth_city_id",
            ,
              wait: true
              success: ()=>
                @model.profile.url = @model.urlRoot() + @model.id + '/profile'
                @model.trigger "change"


          view.on "submit:residence", ()->
            @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
            @model.profile.save
              "residence_country_id": @model.profile.get "residence_country_id"
              "residence_city_id": @model.profile.get "residence_city_id",
            ,
              wait: true
              success: ()=>
                @model.profile.url = @model.urlRoot() + @model.id + '/profile'
                @model.trigger "change"


          view.on "submit:password", ()->
            @model.url = AlumNet.api_endpoint + '/users/' + @model.id + '/change_password'

            @model.save
              "password": @model.profile.get "password"
              "password_confirmation": @model.profile.get "password_confirmation",
            ,
              wait: true
              success: (response)=>
                @model.profile.url = @model.urlRoot() + @model.id + '/profile'
                @model.fetch()
                #Update current user
                if @model.isCurrentUser()
                  AlumNet.request 'get:current_user',
                    refresh: true
                    success: ->
                      #AlumNet.execute('render:users:submenu', undefined, {reset: true})

        when 5  #Experiences
          view.on "childview:save:experience", (childview)->
            model = childview.model
            if model.isValid(true)
              model.formatDates()
              model.save null,
                success: (model)->
                  if model.isEditing then model.isEditing = false
                  model.collection.trigger "reset"

          view.on "childview:cancelEdit", (childview)->
            model = childview.model
            model.isEditing = false
            model.fetch
              success: (model)->
                model.collection.trigger "reset"
            # model.isEditing = false
