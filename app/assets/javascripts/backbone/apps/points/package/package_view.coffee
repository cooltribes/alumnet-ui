@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->

	# class Package.PackagesView extends Marionette.ItemView
	# 	template: 'points/package/templates/packages_list'

	# 	initialize: (options) ->
	# 		console.log options

	# 	templateHelpers: ->
	# 		points: AlumNet.current_user.profile.get('points')


	class Package.PackageView extends Marionette.ItemView
		template: 'points/package/templates/_package'
		#tagName: "li"

		initialize: (options) ->
			console.log options

		 # templateHelpers: ->
		 # 	getDescriptionHtml: ()->
   #       		@description

	class Package.ListView extends Marionette.CompositeView
		template: 'points/package/templates/packages_list'
		childView: Package.PackageView
		childViewContainer: '#packages_container'
		initialize: (options) ->
			#console.log options
			$('#pointsBar').hide();

		# templateHelpers: ->
		# 	name: AlumNet.current_user.profile.get('first_name')
		# 	avatar: AlumNet.current_user.get('avatar')['large']