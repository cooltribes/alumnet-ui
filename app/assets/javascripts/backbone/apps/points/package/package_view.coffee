@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->
	class Package.PackageView extends Marionette.ItemView
		template: 'points/package/templates/_package'
		
		events:
			'click .js-buy':'sendBuy'

		sendBuy: (e)->
			e.preventDefault()
			@trigger 'buy'

		initialize: (options) ->
			@prizeImage = options.model.get('image').image.card.url
			@points = AlumNet.current_user.profile.get('points')
			console.log @points

		templateHelpers: ->
      		points: @points
      		prizeImage: @prizeImage

    class Package.EmptyView extends Marionette.ItemView
    	template: 'points/package/templates/empty'
			
	class Package.ListView extends Marionette.CompositeView
		template: 'points/package/templates/packages_list'
		childView: Package.PackageView
		childViewContainer: '#packages_container'

		events:
			'click #js-modal-points':'showModal'
		
		initialize: (options) ->
			console.log options.models
			$('#pointsBar').hide();

		showModal: (e)->
	      e.preventDefault()
	      modal = new Package.ModalPoints
	      $('#container-modal-points').html(modal.render().el)

	class Package.ModalPoints extends Backbone.Modal
    	template: 'points/package/templates/modal'
    	cancelEl: '#js-close'