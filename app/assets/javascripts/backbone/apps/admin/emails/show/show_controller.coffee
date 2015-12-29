@AlumNet.module 'AdminApp.EmailsShow', (EmailsShow, @AlumNet, Backbone, Marionette, $, _) ->
	class EmailsShow.Controller
		show: (group_id, id)->
			campaign = new AlumNet.Entities.Campaign { group_id: group_id, id: id }
			campaign.fetch
				success: (model)->
					group = AlumNet.request('group:find', group_id)
					group.on 'find:success': ->
						view = new EmailsShow.Campaign
							model: model
							group: group
						AlumNet.mainRegion.show(view)
						AlumNet.execute('render:admin:emails:submenu', undefined, 0)