@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
 
# 

# ESTE View lo copié de Experiences para sacar el script que hace funcionar el slider de los Skills
# Ante la duda preguntar a nelson o a Rafa ( y borrar este comentario ;)

# 





  class Experience.FormAiesec extends Marionette.ItemView
    template: 'registration/skills/templates/form'
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
    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = this.$('#group-avatar')
      formData.append('avatar', file[0].files[0])
      this.model.set(data)
      this.trigger("form:submit", this.model, formData)


  class Experience.ExperienceList extends Marionette.CompositeView
    template: 'registration/experience/templates/experienceList'    
    childView: Experience.FormAiesec
    # childViewContainer: '#exp-list'
    childViewContainer: '.exp-list'
    className: 'row'
    # ui:
    #   'item': '.item'
    #   'commentInput': '.comment'
    #   'likeLink': '.js-vote'
    #   'likeCounter': '.js-likes-counter'
    # events:
    #   'keypress .comment': 'commentSend'
    #   'click .js-like': 'clickedLike'
    #   'click .js-unlike': 'clickedUnLike'
    onShow : ()->
      $( "#slider" ).slider()

    
