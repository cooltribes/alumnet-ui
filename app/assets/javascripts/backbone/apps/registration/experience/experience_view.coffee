@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Experience.FormAiesec extends Marionette.ItemView
    template: 'registration/experience/templates/aiesecExperience'
    # className: 'row'
    # tagName: 'fieldset'
    tagName: 'form'

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          # console.log "bad"
          # console.log view
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')
    
    # onShow: ->
      
    

    ui:
      'btnRmv': '.js-rmvRow'
      # 'commentInput': '.comment'
      # 'likeLink': '.js-vote'
      # 'likeCounter': '.js-likes-counter'
    events:
      "click @ui.btnRmv": "removeExperience"

      
    removeExperience: (e)->
      @model.destroy()


  class Experience.ExperienceList extends Marionette.CompositeView
    template: 'registration/experience/templates/experienceList'    
    childView: Experience.FormAiesec    
    childViewContainer: '#exp-list'
    className: 'row'
    ui:
      'btnAdd': '.js-addExp'
      'btnSubmit': '.js-submit'
    events:
      "click @ui.btnAdd": "addExperience"
      "click @ui.btnSubmit": "submitClicked"

          

    addExperience: (e)->
      newExperience = new AlumNet.Entities.Experience
        type: "aiesec"
      @collection.add(newExperience)


    submitClicked: (e)->
      e.preventDefault()
      
      # formData = new FormData()
      experiences = new Array()

      # console.log @children.length
      
      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
        
      this.trigger("form:submit", @model)

    
