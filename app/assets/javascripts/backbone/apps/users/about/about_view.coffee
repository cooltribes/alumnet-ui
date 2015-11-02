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
      "smoothClick":".smoothClick"
      "facebook":"js-link-fb"
      "twitter":"js-link-tw"
      "web":"js-link-web"

    events:
      "click @ui.addSkill": "addSkill"
      "click @ui.addLanguage": "addLanguage"
      "click @ui.addContact": "addContact"
      "click .smoothClick": "smoothClick"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

      $(window).on 'scroll' , =>
        if $('body').scrollTop()>500
          $('#aboutUseraffix').css
            'position': 'fixed'
            'width' : '181px'
            'top' : '110px'
        else
          if $('html').scrollTop()>500
            $('#aboutUseraffix').css
              'position': 'fixed'
              'width' : '181px'
              'top' : '110px'
          else
            $('#aboutUseraffix').css
              'position': 'relative'
              'top':'0px'
              'width':'100%'

    templateHelpers: ->
      userCanEdit: @userCanEdit

    smoothClick: (e)->
      if $(e.target).prop("tagName")!='a'
        element = $(e.target).closest 'a'
      else
        element = e.target
      String id = $(element).attr("id")
      id = '#'+id.replace('to','')
      $('html,body').animate({
        scrollTop: $(id).offset().top-120
      }, 1000);

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

    #onRender: ->
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
              currentSkills = @view.collection
              
              skills = _.pluck(currentSkills.models, 'attributes')
              listOfNames = _.pluck(skills, 'name')              
              $("#skills-input",@$el).select2 "val", listOfNames 

          # console.log @view.collection
          # console.log $("#skills-input",@$el)   
          # console.log listOfNames

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

  class About.CropAvatarModal extends Backbone.Modal
    template: 'users/about/templates/_cropAvatarModal'
    cancelEl: '#js-close-btn'
    ui:
      'avatarImagen': "#croppic > img"
      'changeProfilePicture': '#js-change-picture'
    
    events:
      'click #js-crop-btn': 'saveImage'
      'change #profile-avatar': 'previewImage'
      'click @ui.changeProfilePicture': 'changePicture'

    changePicture: (e)->
      e.preventDefault()
      $('#profile-avatar').click()

    @isPreview: false
    previewImage: (e)->
      input = @$('#profile-avatar')
      @isPreview = true
      avatarImagen = $(@ui.avatarImagen)
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          avatarImagen.cropper('replace', e.target.result)
        reader.readAsDataURL(input[0].files[0])

    saveImage: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize this
      avatarImagen = $(@ui.avatarImagen)
      if @isPreview
        if data.avatar != ""
          formData = new FormData()
          file = @$('#profile-avatar')
          formData.append('avatar', file[0].files[0])
          user = @model
          esto = @
          user.profile.url = AlumNet.api_endpoint + '/profiles/' + user.profile.id
          user.profile.save formData,
            wait: true
            data: formData
            contentType: false
            processData: false
            success: (model, response, options)->
              user.profile.url = user.urlRoot() + user.id + '/profile'
              user.set("avatar", response.avatar)
              esto.cropAvatar()
      else
        @cropAvatar()

    cropAvatar: ->
      model = @model
      cropBoxData = $(@ui.avatarImagen).cropper('getData')
      imageData = $(@ui.avatarImagen).cropper('getImageData')
      data =
        imgInitH: imageData.naturalHeight
        imgInitW: imageData.naturalWidth
        imgW: imageData.width
        imgH: imageData.height
        imgX1: cropBoxData.x
        imgY1: cropBoxData.y
        cropW: cropBoxData.width
        cropH: cropBoxData.height
        image: 'avatar'
      Backbone.ajax
        url: AlumNet.api_endpoint + "/profiles/#{@model.profile.id}/cropping"
        type: "POST"
        data: data
        success: (data) =>
          console.log("success")
          console.log(data)
          model.trigger('change:cover')
          if model.isCurrentUser()
            AlumNet.current_user.trigger('change:avatar')
        error: (data) =>
          console.log("error")
          console.log(data)

    templateHelpers: ->
      model = @model
      avatar_url: ->
        model.get('avatar').original + "?#{ new Date().getTime() }"

    onShow: ->
      $(@ui.avatarImagen).cropper
        aspectRatio: 1 / 1
        movable: false
        zoomable: false
        rotatable: false
        scalable: false
      
      #model = @model
      #image = @model.get('avatar').original + "?#{ new Date().getTime() }"
      #options =
      #  loadPicture: image
      #  cropData: { "image": 'avatar' }
      #  cropUrl: AlumNet.api_endpoint + "/profiles/#{@model.profile.id}/cropping"
      #  doubleZoomControls:false
      #  rotateControls:false 
      #  onAfterImgCrop: ()->
      #    model.trigger('change:cover')
      #    if model.isCurrentUser()
      #      AlumNet.current_user.trigger('change:avatar')
      #@cropper = new Croppic('croppic', options)



  class About.CropCoverModal extends Backbone.Modal
    template: 'users/about/templates/_cropCoverModal'
    cancelEl: '#js-close-btn'
    events:
      'click #js-crop-btn': 'clickCropAvatar'

    clickCropAvatar: (e)->
      @cropper.crop()

    onShow: ->
      model = @model
      image = @model.get('cover').original + "?#{ new Date().getTime() }"
      options =
        #loadPicture: image
        cropData: { "image": 'cover' }
        uploadUrl: AlumNet.api_endpoint + "/tempfile"
        cropUrl: AlumNet.api_endpoint + "/profiles/#{@model.profile.id}/cropping"
        doubleZoomControls: false
        rotateControls: false 
        customUploadButtonId: 'js-upload-btn'
        onAfterImgUpload: ->
          console.log "imagen upload"
        onAfterImgCrop: ->
          model.trigger('change:cover')

      @cropper = new Croppic('croppic', options)

  class About.CoverModal extends Backbone.Modal
    template: 'users/about/templates/_coverModal'
    cancelEl: '#js-close-btn'
    events:
      'click #js-save': 'saveCover'
      'change #profile-cover': 'previewImage'
      'click #js-croppic': 'showCropModal'

    saveCover: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize this
      if data.cover != ""
        model = @model
        modal = @
        formData = new FormData()
        file = @$('#profile-cover')
        formData.append('cover', file[0].files[0])
        @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
        @model.profile.save formData,
          wait: true
          data: formData
          contentType: false
          processData: false
          success: ()->
            model.trigger('change:cover')
            #modalCrop = new About.CropCoverModal
            #  model: model
            #$('#js-picture-modal-container').html(modalCrop.render().el)
            modal.destroy()


    previewImage: (e)->
      input = @$('#profile-cover')
      preview = @$('#preview-cover')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    showCropModal: (e)->
      e.preventDefault()
      modal = new About.CropCoverModal
        model: @model
      @destroy()
      $('#js-picture-modal-container').html(modal.render().el)

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
          'users/about/templates/_avatarModal'

    cancelEl: '#js-close-btn'
    submitEl: '#js-save'
    keyControl: false
    events:
      'change #js-countries': 'setBirthCities'
      'change #profile-avatar': 'previewImage'
      'click #js-croppic': 'showCropModal'

    initialize: (options)->
      @view = options.view
      #Types of modal (0-name)
      @type = options.type

      console.log this

      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          console.log 'invalid'
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    showCropModal: (e)->
      e.preventDefault()
      modal = new About.CropAvatarModal
        model: @model
      @destroy()
      $('#js-picture-modal-container').html(modal.render().el)

    onShow: ->
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
            file = @$('#profile-avatar')
            formData.append('avatar', file[0].files[0])
            # @view.trigger "submit:avatar", formData
            user = @model
            user.profile.url = AlumNet.api_endpoint + '/profiles/' + user.profile.id
            user.profile.save formData,
              wait: true
              data: formData
              contentType: false
              processData: false
              success: (model, response, options)->
                user.profile.url = user.urlRoot() + user.id + '/profile'
                user.set("avatar", response.avatar)
                user.trigger('change:avatar')
                if user.isCurrentUser()
                  AlumNet.current_user.trigger('change:avatar')

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
      $('#url-archivo').html("File: "+$(e.target).val())
      input = @$('#profile-avatar')
      preview = @$('#preview-avatar')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

  class About.PasswordModal extends Backbone.Modal
    template: 'users/about/templates/_passwordModal'

    cancelEl: '#js-close-btn'
    submitEl: '#js-save'
    keyControl: true

    initialize: (options)->
      @view = options.view
      @user = options.user
      #@model.set("valid_current_password", "true")

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

    beforeSubmit: ()->
      data = Backbone.Syphon.serialize this
      @model.set(data)
      @model.set({valid_current_password: "true"})
      
      if @model.isValid(true)
        url = AlumNet.api_endpoint + "/users/#{@user.id}/change_password"
        data.user_id = @user.id

        Backbone.ajax
          url: url
          type: "POST"
          data: data
          success: (data) =>
            @model.set({valid_current_password: "true"})
            $.growl.notice({ message: 'Password changed successfully' })
            this.destroy()
          error: (data) =>
            if data.responseJSON.error
              @model.set({valid_current_password: "false"})
              @model.validate()
            else
              $.growl.error({ message: 'Unknown error, please contact an admin' })
        return false
      else
        return false

  class About.Profile extends Marionette.ItemView
    template: 'users/about/templates/_profile'

    ui:
      "modalCont": "#js-profile-modal-container"
      "editName": "#js-editName"
      "editBorn": "#js-editBorn"
      "editResidence": "#js-editResidence"
      "editPosition": "#js-editPosition"
      "changePassword": "#js-changePassword"

    events:
      "click @ui.editName": "editName"
      "click @ui.editBorn": "editBorn"
      "click @ui.editResidence": "editResidence"
      "click @ui.changePassword": "changePassword"

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      @privacyOptions = [
        value: 0
        label: "Only me"
      ,
        value: 1
        label: "My friends"
      ,
        value: 2
        label: "Everyone"
      ,
      ]

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
        if model.phone? then model.phone.get "info" else ""

      hasEmail: ->
        model.email_contact?

      position: ->
        if model.profile.get("professional_headline")
          model.profile.get("professional_headline")
        else if model.profile.get("last_experience")
          model.profile.get("last_experience")
        else
          "No Position"

    modelEvents:
      "add:phone:email change": "modelChange"

    onRender: ->
      if @model.phone?
        @stickit @model.phone,
          "[name=privacyPhone]":
            observe: "privacy"
            selectOptions:
              collection: @privacyOptions

        @listenTo(@model.phone, 'change', @changePhone)

      if @model.email_contact?
        @stickit @model.email_contact,
          "[name=privacyEmail]":
            observe: "privacy"
            selectOptions:
              collection: @privacyOptions

        @listenTo(@model.email_contact, 'change', @changeEmail)

      model = @model
      profile = @model.profile
      @ui.editPosition.editable
        type: "text"
        pk: profile.id
        title: "Enter your Professional Header"
        validate: (value)->
          if $.trim(value) == ""
            "this field is required"
        success: (response, newValue)->
          profile.save({'professional_headline': newValue})
          profile.trigger 'change:professional_headline'

    changePhone: ->
      @model.phone.save()

    changeEmail: ->
      @model.email_contact.save()

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

    changePassword: (e)->
      e.preventDefault()
      modal = new About.PasswordModal
        view: this
        model: new AlumNet.Entities.PasswordChange
        user: @model

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
  class About.LanguageNoLevel extends Marionette.ItemView
    template: 'users/about/templates/_languageNoLevel'
    tagName: "li"


  class About.Language extends Marionette.ItemView
    template: 'users/about/templates/_language'
    tagName: "li"

    ui:
      'level': '.progress'

    events:
      "click .js-rmvRow": "removeItem"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    removeItem: (e)->
      if confirm("Are you sure you want to delete this item from your profile ?")
        @model.destroy()
    onRender: ->
      view = this
      @ui.level.tooltip()

  class About.LanguagesView extends Marionette.CollectionView
    # childView: About.Language
    getChildView: ->
      if @showLevel
        About.Language
      else
        About.LanguageNoLevel

    childViewOptions: ->
      userCanEdit: @userCanEdit

    initialize: (options)->
      _.defaults options,
        showLevel: true

      @userCanEdit = options.userCanEdit
      @showLevel = options.showLevel


  #For contact info
  class About.Contact extends Marionette.ItemView
    template: 'users/about/templates/_contact'
    tagName: "li"

    ui:
      "facebook":"#js-link-fb"
      "twitter":"#js-link-tw"
      "web":".js-link-web"
      "yahoo":"js-link-yahoo"
      "email":"js-link-email"
      "mail":"js-link-mail"

    events:
      "click .js-rmvRow": "removeItem"

    modelEvents:
      "change": "modelChange"

    bindings:
      "[name=privacy]":
        observe: "privacy"
        selectOptions:
          collection: [
            value: 0
            label: "Only me"
          ,
            value: 1
            label: "My friends"
          ,
            value: 2
            label: "Everyone"
          ,
          ]

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    removeItem: (e)->
      if confirm("Are you sure you want to delete this item from your profile ?")
        @model.destroy()

    modelChange: (e)->
      @model.save()

    onRender: ->
      view = this
      @stickit()
      @ui.facebook.linkify()
      @ui.twitter.linkify()
      @ui.web.linkify()
      @ui.yahoo.linkify()
      @ui.email.linkify()
      @ui.mail.linkify()


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
    tagName: "div"

    getTemplate: ->
      switch @model.get("asTitle")
        when true
          'users/about/templates/_experienceTitle'
        when false
          'users/about/templates/_experience'

    ui:
      "addExp": "#js-addExp"
      "editExp": "#js-editExp"
      'btnRmv': '.js-rmvRow'
      'description':"#js-description"

    events:
      "click @ui.addExp": "addExp"
      "click @ui.editExp": "editExp"
      "click @ui.btnRmv": "removeItem"

    bindings:
      "[name=privacy]":
        observe: "privacy"
        selectOptions:
          collection: [
            value: 0
            label: "Only me"
          ,
            value: 1
            label: "My friends"
          ,
            value: 2
            label: "Everyone"
          ,
          ]

    modelEvents:
      "change": "modelChange"

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      @model.decodeDates()      

    templateHelpers: ->
      model = @model

      userCanEdit: @userCanEdit

      experienceType: ->
        model.getExperienceType()

      experienceId: ->
        model.getExperienceId()

      getLocation: ->
        model.getLocation()

      getOrganization: ->
        model.getOrganization()

      getStartDate: ->
        model.getStartDate()

      getEndDate: ->
        model.getEndDate()

    onRender: ->
      @stickit()
      @ui.description.linkify()

    addExp: (e)->
      e.preventDefault()
      @trigger "add:exp"

    editExp: (e)->
      e.preventDefault()
      pos = $(e.target).position()
      @model.isEditing = true
      @model.set "first", true
      @model.collection.trigger "reset" #For re-render the itemview
      $('body,html').animate({scrollTop: pos.top + 750}, 400);
      

    removeItem: (e)->
      if @model.canBeDeleted()
        if confirm("Are you sure you want to delete this item from your profile ?")
          @model.destroy()
      else
        alert "You can't delete all your AIESEC experiences"

    modelChange: ->
      if @model.hasChanged("privacy")
        @model.save()
      @render()


  class About.Experiences extends Marionette.CollectionView
    getChildView: (model)->
      if((model.isNew() && !model.get("asTitle")) || model.isEditing)
        AlumNet.Shared.Views.Experiences.FormExperience
      else
        About.Experience

    childViewOptions: ->
      userCanEdit: @userCanEdit
      inProfile: true

    childEvents:
      "add:exp": "addExp"

    initialize: (options)->
      @userCanEdit = options.userCanEdit


    addExp: (childView)->
      newExperience = new AlumNet.Entities.Experience
        exp_type: childView.model.get "exp_type"
        first: true

      index = @collection.indexOf(childView.model)
      @collection.add newExperience,
        at: index + 1


  class About.PublicProfile extends Marionette.LayoutView
    template: 'users/about/templates/public_profile'

    regions:
      profile: "#profile-info"
      skills: "#skills-list"
      languages: "#languages-list"
      experiences: "#experiences-list"

    events:
      'click #js-message-send':'sendMensagge'

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit
      add_timestamp: (file)->
        date = new Date()
        "#{file}?#{date.getTime()}"

    sendMensagge: (e)->
      e.preventDefault()
      AlumNet.trigger('conversation:recipient', null, @model)

