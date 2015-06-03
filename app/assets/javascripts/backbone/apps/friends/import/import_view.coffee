@AlumNet.module 'FriendsApp.Import', (Import, @AlumNet, Backbone, Marionette, $, _) ->

  class Import.Contacts extends Marionette.ItemView
    template: 'friends/import/templates/import_contacts'

    events:
      'click .importMenu>li': 'importOption'
      'click #js-submit-file': 'sendFile'
      'click #js-submit-emails': 'byEnter'
      'click #js-submit-array': 'byUpload'
      'click #js-cancel': 'cancelClicked'
      'change #contacts-file':'showRuteFile'

    ui:
      'messageDiv':'#message'
      'linkUploadFile': '#js-submit-file'
      'linkSubmitArray': '#js-submit-array'
      'contactsList': '#js-contacts-list'
      'linkCancel': '#js-cancel'

    initialize: ->
      document.title='AlumNet - Invite Friends'

    showRuteFile: (e)->
      $('#url-archivo').append("File: "+$(e.target).val())

    onShow: ->
      view = @
      ((url)->
        script = document.createElement('script')
        m = document.getElementsByTagName('script')[0]
        script.async = 1
        script.src = url
        m.parentNode.insertBefore(script, m)
      )('//api.cloudsponge.com/widget/2b05ca85510fb736f4dac18a06b9b6a28004f5fa.js')
      window.csPageOptions =
        textarea_id: "contact_list"
        skipSourceMenu: true
        displaySelectAllNone: false
        afterInit: ()->
          links = document.getElementsByClassName('delayed');
          for link in links
            link.href = '#'
        afterSubmitContacts: (contacts, source, owner)->
          view.byService(contacts)

    byService: (contacts)->
      formatedContacts = []
      _.map contacts, (contact)->
        formatedContacts.push({name: contact.fullName(), email: contact.selectedEmail()})
      @sendInvitations(formatedContacts)

    sendFile: (e)->
      e.preventDefault()
      return if @$('#contacts-file').val() == ''
      view = @
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#contacts-file')
      formData.append('file', file[0].files[0])
      options =
        url: AlumNet.api_endpoint + '/me/contacts/file'
        type: 'POST'
        wait: true
        contentType: false
        processData: false
        data: formData
        error: (xhr)->
          errors = xhr.responseJSON.errors.join(', ')
          view.showMessage('alert', errors)
        success: (data)->
          view.contactsFromFile = data.contacts
          view.showContactsInForm(data.contacts)
      view.showSpin()
      Backbone.ajax options
      $('.menbrete').css('visibility','visible')

    byEnter: (e)->
      e.preventDefault()
      formatedContacts = []
      rawEmails = @$('#js-enter-contacts').val().trim()
      arrayEmails = rawEmails.split(',')
      _.map arrayEmails, (email)->
        formatedContacts.push({name: '', email: email.trim()})
      @sendInvitations(formatedContacts)

    byUpload: (e)->
      e.preventDefault()
      if @contactsFromFile.length > 0
        @sendInvitations(@contactsFromFile)
        @clearUploadForm()
      else
        @showMessage('alert', 'No contacts')

    sendInvitations: (contacts)->
      view = @
      options =
        url: AlumNet.api_endpoint + '/me/send_invitations'
        type: 'POST'
        data: { contacts: contacts }
        error: (xhr)->
          errors = xhr.responseJSON.errors.join(', ')
          view.showMessage('alert', errors)
        success: (data)->
          view.showMessage('success', "Your invitation has been sent to #{data.count} alumni")
      view.showSpin()
      Backbone.ajax options

    showSpin: ->
      @$('#spin').show()
      @ui.messageDiv.hide()

    showMessage: (type, message)->
      @$('#spin').hide()
      if type == 'alert'
        @ui.messageDiv.removeClass('alert-success').addClass('alert-danger')
      else
        @ui.messageDiv.removeClass('alert-danger').addClass('alert-success')
      @ui.messageDiv.html(message).show()

    importOption: (e)->
      e.preventDefault()
      $('.importMenu>li').removeClass "active"
      $(e.target).closest('li').addClass "active"
      $('.importContactForm').hide()
      $('#'+$(e.target).closest('li').attr('id').replace('to-','')).show()

    showContactsInForm: (contacts)->
      @$('#spin').hide()
      if contacts
        html = ""
        _.map contacts, (contact)->
          html += "<li> <div>#{contact.name}</div> <div>#{contact.email}</div> </li>"
        @ui.contactsList.html(html)
        @ui.linkSubmitArray.show()
      else
        @showMessage('alert', 'No contacts')

    cancelClicked: (e)->
      e.preventDefault()
      @clearUploadForm()

    clearUploadForm: ->
      @$('#contacts-file').val('')
      @ui.contactsList.html("")
      @ui.linkSubmitArray.hide()
      @contactsFromFile = null