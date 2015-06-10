@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->
	class Package.Controller
		listPackages: ->
			prizes = AlumNet.request("prize:entities", {})
			page = new Package.ListView
				collection: prizes
			AlumNet.mainRegion.show(page)
			AlumNet.execute('render:points:submenu',undefined,2,true)

