@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->

  class Business.SectionView extends Marionette.LayoutView
    template: 'users/business/templates/business_details'

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      Backbone.Validation.bind @,
        attributes: ["offer"]

      
    templateHelpers: ->
      userCanEdit: @userCanEdit

    triggers:
      "click .js-create": "showCreateForm"
    
    events:      
      "click .js-edit": "editField"
    
    ui:
      "offer": ".js-offer"
      "search": ".js-search"

    # bindings:
    #   ".js-offer": "offer"
    #   ".js-search": "search"
    #   ".js-business-me": "business_me"
    #   ".js-company-name": 
    #     observe: "company"
    #     onGet: (value)->
    #       value.name

    onRender: ->
      view = @     
      
      @ui.offer.editable      
        type: 'textarea'      
        toggle: 'manual'
        validate: (value)->
          view.model.set "offer", value          
          errors = view.model.validate()
            # "offer": value

          if errors?  
            errors.offer
          
        success: (response, newValue)->          
          view.model.save()

      @ui.search.editable      
        type: 'textarea'      
        toggle: 'manual'
        validate: (value)->
          view.model.set "search", value          
          errors = view.model.validate()

          if errors?  
            errors.search
          
        success: (response, newValue)->          
          view.model.save()    
          
    
    editField: (e)->
      e.preventDefault()
      e.stopPropagation()   
      target = $(e.currentTarget).attr("data-target")
      @$(".js-#{target}").editable("toggle")    

  
  
  class Business.CreateForm extends Marionette.ItemView
    template: 'users/business/templates/create_business'

    initialize: ()->      
      Backbone.Validation.bind @,
        valid: (view, attr, selector) ->            
          $el = view.$("[name='#{attr}']")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->          
          $el = view.$("[name='#{attr}']")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    triggers:
      "click .js-cancel": "cancel"

    events:
      "click .js-submit": "submit"
      'change @ui.logo': 'previewImage'

    ui:
      "keywords_offer": "[name = keywords_offer]"
      "keywords_search": "[name = keywords_search]"
      "logo": "[name = company_logo]"
      "previewImage": "#preview-image"

    onRender: ->
      keywords = new AlumNet.Entities.KeywordsCollection [
          { name: "PHP" },
          { name: "Angular" },
          { name: "Backbone" },
          { name: "Marketing" },
          { name: "Rails" }
        ]

      @fillKeywords(keywords)  

      # keywords.fetch
      #   success: (collection) ->
      #     @fillKeywords(collection)  

    submit: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize @
      data.keywords_offer = data.keywords_offer.split(',')
      data.keywords_search = data.keywords_search.split(',')

      formData = new FormData()
      _.forEach data, (value, key, list)->  
        
        # if key == "keywords_offer" 
    
        #   _.forEach value, (value, key, list)->  
        #     formData.append("keywords_offer[#{key}]", value)
        # else    
          formData.append(key, value)

      #Add the image to form submit
      file = @ui.logo
      formData.append('company_logo', file[0].files[0])
      
      @model.set(data)
      
      #submit the model if valid
      unless @model.validate() 
        @trigger "submit", 
          model: @model
          data: data

    previewImage: (e)->
      file = @ui.logo
      preview = @ui.previewImage

      if file[0] && file[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(file[0].files[0])    


    fillKeywords: (collection)->
      keywords = _.pluck(collection.models, 'attributes')
      listOfNames = _.pluck(keywords, 'name')

      @ui.keywords_offer.select2
        tags: listOfNames
        multiple: true
        tokenSeparators: [',', ', ']
        dropdownAutoWidth: true

      @ui.keywords_search.select2
        tags: listOfNames
        multiple: true
        tokenSeparators: [',', ', ']
        dropdownAutoWidth: true



  class Business.EmptyView extends Marionette.ItemView
    template: 'users/business/templates/empty_container'

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    triggers:
      "click .js-create": "showCreateForm"  