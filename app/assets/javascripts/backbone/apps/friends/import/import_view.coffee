@AlumNet.module 'FriendsApp.Import', (Import, @AlumNet, Backbone, Marionette, $, _) ->

  class Import.Contacts extends Marionette.ItemView
    template: 'friends/import/templates/import_contacts'

    events:
      'click .js-submit': 'sendInvitation'

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
        afterSubmitContacts: view.sendInvitation

    sendInvitation: (contacts, source, owner)->
      formatedContacts = []
      _.map contacts, (contact)->
        formatedContacts.push({name: contact.fullName(), email: contact.selectedEmail()})
      options =
        url: AlumNet.api_endpoint + '/me/send_invitations'
        type: 'POST'
        data: { contacts: formatedContacts }
      Backbone.ajax options




  class Import.Networks extends Marionette.ItemView
    template: 'friends/import/templates/import_networks'

    events:
    	"click .importMenu>li": "importOption"

    importOption: (e)->
    	$('.importMenu>li').removeClass "active"
    	$(e.target).closest('li').addClass "active"
    	$('.importContactForm').hide()
    	$('#'+$(e.target).closest('li').attr('id').replace('to-','')).show()

