@AlumNet.module 'FilesApp.Folders', (Folders, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Folders.EmptyView extends Marionette.ItemView
    template: 'files/folders/list/templates/_empty'
    initialize: (options)->
      @message = options.message
  
    templateHelpers: ->
      message: @message


  class Folders.FolderView extends Marionette.ItemView
    template: 'files/folders/list/templates/_folder'
    className: 'col-md-3 col-sm-6'
    
    triggers:
      'click .js-detail': "show:detail"
    
    events:
      'click .js-rmvItem': "removeItem"
      # event: 'view:detail'
      # preventDefault: true
      
    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit  

    removeItem: (e)->
      e.preventDefault()
      if confirm("Are you sure you want to delete this folder and all its files?")
        @model.destroy
          wait: true
    

  class Folders.FoldersView extends Marionette.CompositeView
    template: 'files/folders/list/templates/folders_container'
    childView: Folders.FolderView
    emptyView: Folders.EmptyView
    emptyViewOptions: 
      message: "There are no folders here"
    childViewContainer: '.folders-list'
    childViewOptions: ->
      userCanEdit: @userCanEdit
      
    ui:
      "modals": "#js-modal-container"
    
    events:
      'click .js-create': 'createFolder'

    initialize: (options)->
      @userCanEdit = options.userCanEdit


    templateHelpers: ->
      userCanEdit: @userCanEdit

    createFolder: (e)->
      e.preventDefault()
      @trigger "new:folder"      


  class Folders.FolderModal extends Backbone.Modal
    template: 'files/folders/list/templates/_folderModal'    

    cancelEl: '#js-close'
    submitEl: '#js-save'
    keyControl: false    

    events:
      "submit form": "submitForm"

    bindings:
      "[name=name]": "name"  

    initialize: (options)->      
      
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

    onRender: ()->
      @stickit()

    submitForm: (e)->
      e.preventDefault()
      @triggerSubmit()
    # templateHelpers: ->     
      # isNew: @model.isNew()

    beforeSubmit: ()->
      #Validations
      @model.isValid(true)



    submit: ()->  
      @trigger "submit"
