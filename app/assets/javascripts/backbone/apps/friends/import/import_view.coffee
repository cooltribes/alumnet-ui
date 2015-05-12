@AlumNet.module 'FriendsApp.Import', (Import, @AlumNet, Backbone, Marionette, $, _) ->

  class Import.Contacts extends Marionette.ItemView
    template: 'friends/import/templates/import_contacts'

    events:
      'click .importMenu>li': 'importOption'
      'click #js-submit-file': 'sendFile'
      'click #js-submit-emails': 'sendEmails'

    ui:
      'messageDiv':'#message'

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
          view.sendContacts(contacts, view)

    sendContacts: (contacts, view)->
      formatedContacts = []
      _.map contacts, (contact)->
        formatedContacts.push({name: contact.fullName(), email: contact.selectedEmail()})
      options =
        url: AlumNet.api_endpoint + '/me/send_invitations'
        type: 'POST'
        data: { contacts: formatedContacts }
        error: (xhr)->
          errors = xhr.responseJSON.errors.join(', ')
          view.showMessage('alert', errors)
        success: (data)->
          view.showMessage('success', "Your invitation has been sent to #{data.count} alumni")
      @$('#spin').show()
      Backbone.ajax options

    sendFile: (e)->
      e.preventDefault()
      view = @
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#contacts-file')
      formData.append('contacts', file[0].files[0])
      options =
        url: AlumNet.api_endpoint + '/me/send_invitations'
        type: 'POST'
        wait: true
        contentType: false
        processData: false
        data: formData
        error: (xhr)->
          errors = xhr.responseJSON.errors.join(', ')
          view.showMessage('alert', errors)
        success: (data)->
          view.showMessage('success', "Your invitation has been sent to #{data.count} alumni")
      @$('#spin').show()
      Backbone.ajax options

    sendEmails: (e)->
      e.preventDefault
      view = @
      formatedContacts = []
      rawEmails = @$('#js-enter-contacts').val().trim()
      arrayEmails = rawEmails.split(',')
      _.map arrayEmails, (email)->
        formatedContacts.push({name: '', email: email.trim()})
      options =
        url: AlumNet.api_endpoint + '/me/send_invitations'
        type: 'POST'
        data: { contacts: formatedContacts }
        error: (xhr)->
          errors = xhr.responseJSON.errors.join(', ')
          view.showMessage('alert', errors)
        success: (data)->
          view.showMessage('success', "Your invitation has been sent to #{data.count} alumni")
      @$('#spin').show()
      Backbone.ajax options

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