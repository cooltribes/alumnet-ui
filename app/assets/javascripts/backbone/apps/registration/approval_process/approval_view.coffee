@AlumNet.module 'RegistrationApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->

	# class Approval.Form extends Marionette.LayoutView
 #      # template: 'registration/Approval_process/templates/layout'
 #    	template: 'registration/Approval_process/templates/layout'
 #    	id: 'main-wrapper'
 #    	className: 'col-md-12'

 #    	regions:
 #      		side_region: '#sidebar-region' #any name you want to give to the region, any css selector you have used inside the layout template
 #      		content_region:   '#registration-content-region' #any name you want to give to the region, any css selector you have used inside the layout template


 #  	class Approval.Sidebar extends Marionette.CompositeView
 #    	template: 'registration/account/templates/sidebar'

	class Approval.Form extends Marionette.ItemView
  	template: 'registration/approval_process/templates/formTemporal'  