@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->

  class Business.SectionView extends Marionette.LayoutView
    template: 'users/business/templates/business_details'

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      Backbone.Validation.bind @,
        attributes: ["offer"]

      @keywords = new AlumNet.Entities.KeywordsCollection [
          { name: "PHP" },
          { name: "Angular" },
          { name: "Backbone" },
          { name: "Marketing" },
          { name: "Rails" }
        ]  

      
    templateHelpers: ->
      userCanEdit: @userCanEdit

    triggers:
      "click .js-create": "showCreateForm"
    
    events:      
      "click .js-edit": "editField"
    
    ui:
      "offer": ".js-offer"
      "search": ".js-search"
      "business_me": ".js-business-me"
      "keywords_offer": ".js-kwO"
      "keywords_search": ".js-kwS"

    onRender: ->
      #Make the fields editable as text
      @ui.offer.editable @editableParams("offer")
      @ui.search.editable @editableParams("search")        
      @ui.business_me.editable @editableParams("business_me")             
        
      #Make the fields editable as select2 with multiple options
      @ui.keywords_offer.editable @tagEditableParams("offer_keywords")
      @ui.keywords_search.editable @tagEditableParams("search_keywords")

          
    tagEditableParams: (field)->    
      view = @          
         
      select2: 
        tags: @fillKeywords()     
        multiple: true
        tokenSeparators: [',', ', ']
        dropdownAutoWidth: true     
      type: "select2" 
      toggle: 'manual'
      # display: (value, sourceData, response)->
      #    #display checklist as comma-separated values
      #   # html = []
      #   # checked = $.fn.editableutils.itemsByValue(value, sourceData);                   
        # _.each value ... AQUI SE ARMA el HTML        
        # if checked.length
        #   $.each checked, (i, v) ->
        #     html.push($.fn.editableutils.escape(v.text));

        #   $(this).html(html.join(', '));
        # else
        # $(this).empty();         
        
      
      validate: (value)->
        view.model.set field, value      
        errors = view.model.validate()
        console.log view.model
        if errors?  
          errors[field]
      success: (response, newValue)->                  
        view.model.save()      
        
    editableParams: (field)->
      view = @     

      type: 'textarea'      
      toggle: 'manual'
      validate: (value)->
        view.model.set field, value          
        errors = view.model.validate()
        if errors?  
          errors[field]        
      success: (response, newValue)->          
        view.model.save()      


    editField: (e)->
      e.preventDefault()
      e.stopPropagation()   
      target = $(e.currentTarget).attr("data-target")
      @$(".js-#{target}").editable("toggle")    

    
    fillKeywords: ()->
      keywords = _.pluck(@keywords.models, 'attributes')
      _.pluck(keywords, 'name')

  
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
      "offer_keywords": "[name = offer_keywords]"
      "search_keywords": "[name = search_keywords]"
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
      data.offer_keywords = data.offer_keywords.split(',')
      data.search_keywords = data.search_keywords.split(',')

      formData = new FormData()
      _.forEach data, (value, key, list)->  
        
        # if key == "keywords_offer" 
    
        #   _.forEach value, (value, key, list)->  
        #     formData.append("keywords_offer[#{key}]", value)
        # else    
          formData.append(key, value)

      #Add the image to form submit
      # file = @ui.logo
      # formData.append('company_logo', file[0].files[0])
      
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

      @ui.offer_keywords.select2
        tags: listOfNames
        multiple: true
        tokenSeparators: [',', ', ']
        dropdownAutoWidth: true

      @ui.search_keywords.select2
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