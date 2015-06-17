@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->
	class Package.PackageView extends Marionette.ItemView
		template: 'points/package/templates/_package'
		
		events:
			'click .js-buy':'sendBuy'

		sendBuy: (e)->
			e.preventDefault()
			@trigger 'buy'

	class Package.ListView extends Marionette.CompositeView
		template: 'points/package/templates/packages_list'
		childView: Package.PackageView
		childViewContainer: '#packages_container'
		initialize: (options) ->
			$('#pointsBar').hide();