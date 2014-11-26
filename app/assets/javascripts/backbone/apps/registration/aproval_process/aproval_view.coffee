@AlumNet.module 'RegistrationApp.Aproval', (Aproval, @AlumNet, Backbone, Marionette, $, _) ->

	class Aproval.Form extends Marionette.LayoutView
    	template: 'registration/aproval_process/templates/layout'
    	id: 'main-wrapper'
    	className: 'col-md-12'

    	regions:
      		side_region: '#sidebar-region' #any name you want to give to the region, any css selector you have used inside the layout template
      		content_region:   '#registration-content-region' #any name you want to give to the region, any css selector you have used inside the layout template


  	class Aproval.Sidebar extends Marionette.CompositeView
    	template: 'registration/account/templates/sidebar'

	class Aproval.Form extends Marionette.ItemView
    	template: 'registration/aproval_process/templates/form'  