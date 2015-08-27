@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Admin extends Marionette.ItemView
    template: 'admin/users/show/templates/admin'
    className: 'container'

    ui:
      'adminNote': 'textarea#admin-note'
      'tags': 'input#tags'
      'saveNote': 'a#js-save-note'
      'saveTags': 'a#js-save-tags'

    events:
      'click @ui.saveNote': 'saveNoteClicked'
      'click @ui.saveTags': 'saveTagsClicked'

    onShow: ->
      tags = new Bloodhound
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
        queryTokenizer: Bloodhound.tokenizers.whitespace
        prefetch: AlumNet.api_endpoint + '/tags/'
        remote:
          wildcard: '%query'
          url: AlumNet.api_endpoint + '/tags/?q[name_cont]=%query'

      @ui.tags.tagsinput
        typeaheadjs:
          name: 'tags'
          displayKey: 'name'
          valueKey: 'name'
          source: tags

    saveNoteClicked: (e)->
      e.preventDefault()
      model = @model
      note = @ui.adminNote.val()
      Backbone.ajax
        method: 'post'
        url: AlumNet.api_endpoint + "/admin/users/#{@model.id}/note"
        data: { note: note }
        success: (data)->
          model.set('admin_note', note)
        error: (response)->
          message = AlumNet.formatErrorsFromApi(response.responseJSON)
          $.growl.error(message: message)

    saveTagsClicked: (e)->
      e.preventDefault()
      tags = @ui.tags.val()
      @model.save { tag_list: tags },
        error: (model, response)->
          message = AlumNet.formatErrorsFromApi(response.responseJSON)
          $.growl.error(message: message)
