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

    initialize: ->
      # Backbone.Validation.bind this,
        # collection: @collection
        # valid: (view, attr, selector) ->
        #   console.log "valid"
        #   $el = view.$("[name=#{attr}]")
        #   $group = $el.closest('.form-group')
        #   $group.removeClass('has-error')
        #   $group.find('.help-block').html('').addClass('hidden')
        # invalid: (view, attr, error, selector) ->
        #   console.log "invalid"
        #   console.log view
          # $el = view.$("[name=#{attr}]")
          # $el = view.$("[id=#{attr}]")
          # $group = $el.closest('.form-group')
          # $group.addClass('has-error')
          # $group.find

    addExperience: (e)->
      newExperience = new AlumNet.Entities.Experience
      @collection.add(newExperience)


    submitClicked: (e)->
      e.preventDefault()
      
      # formData = new FormData()
      experiences = new Array()

      console.log @children.length
      
      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
        # console.log "vista " + itemView.cid
        # console.log itemView.model
        # _.forEach data, (valueIn, key, list)->

        # if valueIn != "" and contactArray.info[key] != ""
        #   experiences[key] = {
        #     "name": valueIn,
        #     "info": contactArray.info[key],
        #     "privacy": contactArray.privacy[key],
        #   }
        # console.log valueIn
      # file = this.$('#group-avatar')
      # console.log @collection.at(0)
      # @collection.at(0).set "name", ""
      # @collection.model.set(data)
      # console.log @collection.at(0).validate()
      # console.log @collection.at(0).validate()
      # @collection.at(0).isValid(true)
      # formData.append('avatar', file[0].files[0])
      this.trigger("form:submit", @model)

    
