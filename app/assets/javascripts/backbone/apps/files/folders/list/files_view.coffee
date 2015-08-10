@AlumNet.module 'FilesApp.Folders', (Folders, @AlumNet, Backbone, Marionette, $, _) ->
  
  
  class Folders.FileView extends Marionette.ItemView
    template: 'files/folders/list/files_templates/_file'
    className: 'col-md-4 col-sm-6 margin_bottom_small'
    
    triggers:
      'click .js-moveFile': "move:file"
      'click .js-editItem': "show:edit"
    
    events:
      'click .js-rmvItem': "removeItem"
        
    removeItem: (e)->
      e.preventDefault()
      if confirm("Are you sure you want to delete this file?")
        @model.destroy
          wait: true
    

  class Folders.FilesView extends Marionette.CompositeView
    template: 'files/folders/list/files_templates/files_container'
    childView: Folders.FileView
    emptyView: Folders.EmptyView
    emptyViewOptions: 
      message: "There are no files here"
    childViewContainer: '.files-list'    
      
    ui:
      "modals": "#js-modal-container"
      "uploadBtn": ".js-upload"
      "loadingBar": ".js-loading"
       
    
    triggers:
      'click .js-return': 'return'

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

    onShow: ->      
      #Init the file uploader
      uploader = new AlumNet.Utilities.PluploaderFolders($(".js-upload", @.$el).get(), @).uploader               
      uploader.init()    

    showUploading: ()-> 
      @ui.uploadBtn.hide()      
      @ui.loadingBar.slideDown()
    
    hideUploading: ()-> 
      @ui.uploadBtn.show()
      @ui.loadingBar.slideUp()
      $.growl.notice 
        title: "Files"
        message: "All files have been uploaded successfully"

    checkDuplicated: (files)->
      @collection.checkDuplicated files
  

  class Folders.MoveFileModal extends Backbone.Modal
    template: 'files/folders/list/files_templates/move_file_modal'    

    cancelEl: '#js-close'
    submitEl: '#js-save'
    keyControl: false    

    events:
      "submit form": "submitForm"
    
    initialize: (options)->      
      @folder_id = options.folder_id
      
    templateHelpers: ->
      folder_id: @folder_id
    
    # onRender: ()->
    #   @stickit()

    submitForm: (e)->
      e.preventDefault()
      @triggerSubmit()
    # templateHelpers: ->     
      # isNew: @model.isNew()

    beforeSubmit: ()->
      #Validations
      data = Backbone.Syphon.serialize @      
      @folder_id = parseInt(data.folder_id)      
      (@folder_id?) && Number.isInteger(@folder_id) && (@folder_id > 0)

      
    submit: ()->  
      @trigger "submit", @folder_id


  class Folders.FileModal extends Backbone.Modal
    template: 'files/folders/list/files_templates/_fileModal'    

    cancelEl: '#js-close'
    submitEl: '#js-save'
    keyControl: false    

    events:
      "submit form": "submitForm"

    initialize: (options)->      
      @previousName = @model.get "name"

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

    onShow: ()->
      @$("[name=name]").select()

    submitForm: (e)->
      e.preventDefault()
      @triggerSubmit()
    
    templateHelpers: ->     
      isNew: @model.isNew()

    beforeSubmit: ()->
      #Validations
      data = Backbone.Syphon.serialize this
      @model.set data
      @model.isValid(true)

    cancel: ()->  
      @model.set "name", @previousName

    submit: ()->  
      @trigger "submit"  