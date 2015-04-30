@AlumNet.module 'PointsApp.Earned', (Earned, @AlumNet, Backbone, Marionette, $, _) ->

  class Earned.EarnedView extends Marionette.ItemView
    template: 'points/earned/templates/earned_list'
    initialize: (options) ->
    	$('#pointsBar').hide();
    
    templateHelpers: ->
    	name: AlumNet.current_user.profile.get('first_name')
    	avatar: AlumNet.current_user.get('avatar')['large']