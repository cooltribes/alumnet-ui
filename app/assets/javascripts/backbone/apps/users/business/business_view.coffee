@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->

  class Business.SectionView extends Marionette.LayoutView
    template: 'users/business/templates/business_details'

    regions:
      links_region: ".js-links-region"

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      Backbone.Validation.bind @,
        attributes: ["offer"]

      @keywords = options.keywords

      
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
      # view = @     
      # @ui.company_name.editable
      #   type: 'textarea'      
      #   toggle: 'manual'
      #   validate: (value)->
      #     view.model.set field, value          
      #     errors = view.model.validate()
      #     if errors?  
      #       errors[field]        
      #   success: (response, newValue)->          
      #     view.model.save()    


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

  class Business.EmptyLinkView extends Marionette.ItemView
    template: 'users/business/templates/_emptyLinks'

    
  class Business.LinkView extends Marionette.ItemView
    template: 'users/business/templates/_link'

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      Backbone.Validation.bind @ #For model validations to work


    templateHelpers: ()->
      userCanEdit: @userCanEdit

    ui:
      "title": ".js-title"  
      "description": ".js-description"  
      "url": ".js-url"  
    
    events:    
      "click .js-edit": "editItem"  
      "click .js-delete": "deleteItem"  

    editItem: (e)->
      e.preventDefault()      
      e.stopPropagation()   
      target = $(e.currentTarget).attr("data-target")
      @$(".js-#{target}").editable("toggle")      
      
      
    deleteItem: (e)->
      e.preventDefault()
      if confirm("Are you sure you want to delete this link?")
        @model.destroy()

    onRender: ()->
      if @userCanEdit
        @ui.title.editable @editableParams("title")
        @ui.description.editable @editableParams("description")
        @ui.url.editable @editableParams("url")

    editableParams: (field)->
      view = @     

      type: 'text'      
      toggle: 'manual'
      validate: (value)->
        view.model.set field, value          
        errors = view.model.validate()
        if errors?  
          errors[field]        
      success: (response, newValue)->          
        view.model.save()        
 
 
  class Business.LinksView extends Marionette.CompositeView
    template: 'users/business/templates/links_container'
    childView: Business.LinkView
    emptyView: Business.EmptyLinkView
    childViewContainer: ".js-links"
    childViewOptions: ()->
      userCanEdit: @userCanEdit      

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      @model = new AlumNet.Entities.Link

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

    templateHelpers: ()->
      userCanEdit: @userCanEdit
          

    events:
      "submit .js-linkForm": "saveLink"

    bindings:
      "[name=title]": "title"
      "[name=description]": "description"
      "[name=url]": "url"

    onRender: ()->
      if @userCanEdit
        @stickit()
      

    saveLink: (e)->
      e.preventDefault()
      unless @model.validate()        
        @collection.create @model.attributes,
          wait: true
        @model.clear()
        # console.log "listo"


  
  class Business.CreateForm extends Marionette.ItemView
    template: 'users/business/templates/create_business'

    initialize: (options)->      
      @keywords = options.keywords      
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
      @fillKeywords()  

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


    fillKeywords: ()->
      keywords = _.pluck(@keywords.models, 'attributes')
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