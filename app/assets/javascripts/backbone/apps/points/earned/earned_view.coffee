@AlumNet.module 'PointsApp.Earned', (Earned, @AlumNet, Backbone, Marionette, $, _) ->
	class Earned.EarnedView extends Marionette.ItemView
		template: 'points/earned/templates/_earned'
		#tagName: "li"

		templateHelpers: ->
			getCreatedTime: ()->
        		moment(@user_action.created_at).fromNow()

	class Earned.ListView extends Marionette.CompositeView
		template: 'points/earned/templates/earned_list'
		childView: Earned.EarnedView
		childViewContainer: '#points_container'
		initialize: (options) ->
			console.log options
			$('#pointsBar').hide();

		templateHelpers: ->
			name: AlumNet.current_user.profile.get('first_name')
			avatar: AlumNet.current_user.get('avatar')['large']