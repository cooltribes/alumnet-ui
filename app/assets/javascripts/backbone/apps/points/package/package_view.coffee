@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->
	class Package.PackageView extends Marionette.ItemView
		template: 'points/package/templates/_package'
		
		events:
			'click .js-buy':'sendBuy'

		sendBuy: (e)->
			e.preventDefault()
			@trigger 'buy'

		initialize: (options) ->
			#console.log "opciones"
			console.log options
			@points = AlumNet.current_user.profile.get('points')
			console.log @points

		templateHelpers: ->
      		points: @points

	class Package.ListView extends Marionette.CompositeView
		template: 'points/package/templates/packages_list'
		childView: Package.PackageView
		childViewContainer: '#packages_container'
		initialize: (options) ->
			#console.log options
			$('#pointsBar').hide();