@AlumNet.module 'UsersApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      user = AlumNet.request("user:find", id)
      user.on 'find:success', (response, options)->
        
        layout = AlumNet.request("user:layout", user, 1)
        header = AlumNet.request("user:header", user, 1)
        
        #todo: implement a function to return the view. like a discovery module
        
        profileId = user.profile.id

        #get the skills of the user
        skills = new AlumNet.Entities.Skills
        # skills.url = AlumNet.api_endpoint + '/profile/' + profileId + "/skills"
        skills.fetch
          error: (collection, response, options) ->
            # console.log "Error"            
          success: (collection, response, options) ->
            # console.log "Exito"

        #get the languages of the user
        languages = new AlumNet.Entities.Languages
        # languages.url = AlumNet.api_endpoint + '/profile/' + profileId + "/language_levels"
        languages.fetch
          error: (collection, response, options) ->
            # console.log "Error"            
          success: (collection, response, options) ->
            # console.log "Exito"

        #get the contacts of the user
        contacts = new AlumNet.Entities.ProfileContactsCollection
        contacts.url = AlumNet.api_endpoint + '/languages'
        # contacts.url = AlumNet.api_endpoint + '/profile/' + profileId + "/contact_infos"
        contacts.fetch
          error: (collection, response, options) ->
            # console.log "Error"            
          success: (collection, response, options) ->
            # console.log "Exito"

        console.log contacts


        body = new About.View
          model: user

        skillsView = new About.SkillsView
          collection: skills

        languagesView = new About.LanguagesView
          collection: languages

        contactsView = new About.ContactsView
          collection: contacts


        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)

        #Show each region of the about page
        body.skills.show(skillsView)
        body.languages.show(languagesView)
        body.contacts.show(contactsView)



        AlumNet.execute('render:users:submenu')





        # body.on 'group:edit:description', (model, newValue) ->
        #   model.save({description: newValue})

        # body.on 'group:edit:group_type', (model, newValue) ->
        #   model.save({group_type: parseInt(newValue)})



      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
        