@AlumNet.module 'PointsApp.Earned', (Earned, @AlumNet, Backbone, Marionette, $, _) ->
	class Earned.EarnedView extends Marionette.ItemView
		template: 'points/earned/templates/_earned'
		#tagName: "li"

		initialize: (options) ->
			@object_class = options.model.get('class')
			@history = options.model.get('history')


		templateHelpers: ->
			object_class: @object_class
			history: @history
			action: @history.action
			getCreatedTime: ()->
				if @object_class == 'UserAction'
					moment(@history.user_action.created_at).fromNow()	
				else if @object_class == 'UserPrize'
					moment(@history.user_prize.created_at).fromNow()
        		

	class Earned.EmptyView extends Marionette.ItemView
    	template: 'points/earned/templates/empty'
    	
	class Earned.ListView extends Marionette.CompositeView
		template: 'points/earned/templates/earned_list'
		childView: Earned.EarnedView
		childViewContainer: '#points_container'
		initialize: (options) ->
			$('#pointsBar').hide();

		templateHelpers: ->
			name: AlumNet.current_user.profile.get('first_name')
			avatar: AlumNet.current_user.get('avatar')['large']