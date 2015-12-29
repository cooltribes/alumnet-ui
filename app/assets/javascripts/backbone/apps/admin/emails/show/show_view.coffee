@AlumNet.module 'AdminApp.EmailsShow', (EmailsShow, @AlumNet, Backbone, Marionette, $, _) ->

  class EmailsShow.Campaign extends Marionette.ItemView
    template: 'admin/emails/show/templates/campaign'
    className: 'container'

    initialize: (options)->
    	@group = options.group
    	document.title = 'AlumNet - Campaign Details'

    templateHelpers: ->
    	membersCount: @group.get('members').length