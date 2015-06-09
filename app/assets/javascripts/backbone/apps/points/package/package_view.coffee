@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->

	class Package.PackagesView extends Marionette.ItemView
		template: 'points/package/templates/packages_list'

		initialize: (options) ->
			console.log options

		templateHelpers: ->
			points: AlumNet.current_user.profile.get('points')