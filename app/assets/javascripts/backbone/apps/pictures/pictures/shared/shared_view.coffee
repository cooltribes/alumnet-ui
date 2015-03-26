@AlumNet.module 'PicturesApp.PictureShared', (PictureShared, @AlumNet, Backbone, Marionette, $, _) ->
  class PictureShared.PictureModal extends Backbone.Modal
    template: 'pictures/pictures/shared/templates/_detailModal'
    className: "picture-modal"
    cancelEl: '.js-close'
    # submitEl: '#js-save'
    keyControl: false
    # prefix: "picture"

    # events:      

    initialize: (options)->
      @view = options.view
      
      # Backbone.Validation.bind this,
      #   valid: (view, attr, selector) ->
      #     $el = view.$("[name=#{attr}]")
      #     $group = $el.closest('.form-group')
      #     $group.removeClass('has-error')
      #     $group.find('.help-block').html('').addClass('hidden')
      #   invalid: (view, attr, error, selector) ->
      #     $el = view.$("[name=#{attr}]")
      #     $group = $el.closest('.form-group')
      #     $group.addClass('has-error')
      #     $group.find('.help-block').html(error).removeClass('hidden')

    templateHelpers: ->
     
      model = @model
      console.log model
    
      getLocation: ->
        model.getLocation()


  API =
    getPictureModal: (picture)->      
      new PictureShared.PictureModal
        model: picture        


  AlumNet.reqres.setHandler 'picture:modal', (picture) ->
    API.getPictureModal(picture)
