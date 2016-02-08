@AlumNet.module 'BusinessExchangeApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
	class Profile.BusinessProfiles extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Profile