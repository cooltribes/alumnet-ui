@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Experience.FormAiesec extends Marionette.ItemView
    template: 'registration/experience/templates/aiesecExperience'
    # className: 'row'
    tagName: 'fieldset'

    initialize: ->
      ###Backbone.Validation.bind this,
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
    events:
      "click button.js-submit":"submitClicked"
      
      ###
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
    # childViewContainer: '#exp-list'
    childViewContainer: '#exp-list'
    className: 'row'
    ui:
      'btnAdd': '.js-addExp'
      'btnSubmit': '.js-submit'
      # 'commentInput': '.comment'
      # 'likeLink': '.js-vote'
      # 'likeCounter': '.js-likes-counter'
    events:
      "click @ui.btnAdd": "addExperience"
      "click @ui.btnSubmit": "submitClicked"
      # "click button.js-rmvRow":"removeInputRow"
      # "click button.js-submit":"submitClicked"

    addExperience: (e)->
      newExperience = new AlumNet.Entities.Experience
      this.collection.add(newExperience)


    submitClicked: (e)->
      e.preventDefault()
      
      # formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      experiences = new Array()
      _.forEach data, (valueIn, key, list)->
        # if valueIn != "" and contactArray.info[key] != ""
        #   experiences[key] = {
        #     "name": valueIn,
        #     "info": contactArray.info[key],
        #     "privacy": contactArray.privacy[key],
        #   }
        console.log valueIn
      # file = this.$('#group-avatar')
      # formData.append('avatar', file[0].files[0])
      # this.model.set(data)
      # this.trigger("form:submit", this.model, formData)

    
