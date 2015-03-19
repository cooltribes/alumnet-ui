@AlumNet.module 'HomeApp.Prueba', (Prueba, @AlumNet, Backbone, Marionette, $, _) ->
  class Prueba.View extends Marionette.ItemView
    template: 'home/prueba/templates/prueba'

    onShow:->
      avatar = AlumNet.current_user.get('avatar').original
      options =
        loadPicture: avatar
        uploadUrl:'img_save_to_file.php',
        cropUrl:'img_crop_to_file.php',
        enableMousescroll:true

      cropper = new Croppic('croppic', options)
      console.log cropper, avatar
