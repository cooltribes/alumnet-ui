@AlumNet.module 'FilesApp.Folders', (Folders, @AlumNet, Backbone, Marionette, $, _) ->
  
  
  class Folders.FileView extends Marionette.ItemView
    template: 'files/folders/list/files_templates/_file'
    className: 'col-md-3 col-sm-6 file__background'
    
    triggers:
      'click .js-moveFile': "move:file"
    
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

    checkDuplicated: (file_names)->
      duplicated_name = @collection.checkDuplicated file_names

      if duplicated_name
        alert "A file with the name \"" + duplicated_name + "\" already exists in this folder. You have to change the name before upload it." 
        return false
        
      true    
      

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
  