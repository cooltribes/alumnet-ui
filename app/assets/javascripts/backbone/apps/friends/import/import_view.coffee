@AlumNet.module 'FriendsApp.Import', (Import, @AlumNet, Backbone, Marionette, $, _) ->

  class Import.Contacts extends Marionette.ItemView
    template: 'friends/import/templates/import_container'

  
  class Import.Networks extends Marionette.ItemView
    template: 'friends/import/templates/import_networks'

    events:
    	"click .importMenu>li": "importOption"

    importOption: (e)->
    	$('.importMenu>li').removeClass "active"
    	$(e.target).closest('li').addClass "active"
    	$('.importContactForm').hide()
    	$('#'+$(e.target).closest('li').attr('id').replace('to-','')).show()
