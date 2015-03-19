@AlumNet.module 'PicturesApp.UploadPicture', (UploadPicture, @AlumNet, Backbone, Marionette, $, _) ->
  
  class UploadPicture.Modal extends Backbone.Modal
    template: 'pictures/pictures/upload/templates/uploadModal'  

    cancelEl: '.js-close'
    submitEl: '#js-save'
    keyControl: false

    events:
      'change #picture-file': 'previewImage'

    initialize: (options)->
      # @album = options.album
      @view = options.view

      @model = new AlumNet.Entities.Picture       
      
    onRender: ->
      switch @type
        when 0
          skillsList = new AlumNet.Entities.Skills
          skillsList.fetch
            success: =>
              @fillSkills(skillsList)

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
      data = Backbone.Syphon.serialize this
      if data.picture != ""          
        formData = new FormData()
        file = @$('#picture-file')
        formData.append('picture', file[0].files[0])            
        @view.trigger "upload:picture", formData 

    previewImage: (e)->
      file = @$('#picture-file')      
      preview = @$('#preview-picture')
      if file[0] && file[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(file[0].files[0])      