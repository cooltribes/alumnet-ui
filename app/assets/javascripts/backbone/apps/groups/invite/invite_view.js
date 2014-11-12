// Generated by CoffeeScript 1.6.3
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.AlumNet.module('GroupsApp.Invite', function(Invite, AlumNet, Backbone, Marionette, $, _) {
  var _ref, _ref1;
  this.AlumNet = AlumNet;
  Invite.User = (function(_super) {
    __extends(User, _super);

    function User() {
      _ref = User.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    User.prototype.template = 'groups/invite/templates/user';

    User.prototype.tagName = 'div';

    User.prototype.className = 'col-md-4';

    User.prototype.initialize = function(options) {
      return this.parentModel = options.parentModel;
    };

    User.prototype.templateHelpers = function() {
      var view;
      view = this;
      return {
        wasInvited: function() {
          var group_id, user_group_ids;
          group_id = view.parentModel.get('id');
          user_group_ids = this.groups;
          return _.contains(user_group_ids, group_id);
        }
      };
    };

    User.prototype.ui = {
      invitation: ".invitation",
      inviteLink: "a.js-invite"
    };

    User.prototype.events = {
      'click a.js-invite': 'clickInvite'
    };

    User.prototype.clickInvite = function(e) {
      e.preventDefault();
      return this.trigger('invite');
    };

    User.prototype.removeLink = function() {
      this.ui.inviteLink.remove();
      return this.ui.invitation.append('<span>Invited</span>');
    };

    return User;

  })(Marionette.ItemView);
  return Invite.Users = (function(_super) {
    __extends(Users, _super);

    function Users() {
      _ref1 = Users.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Users.prototype.template = 'groups/invite/templates/users_container';

    Users.prototype.childView = Invite.User;

    Users.prototype.childViewContainer = ".users-list";

    Users.prototype.childViewOptions = function() {
      return {
        parentModel: this.model
      };
    };

    Users.prototype.events = {
      'click .js-search': 'performSearch'
    };

    Users.prototype.performSearch = function(e) {
      var $searchForm, data;
      e.preventDefault();
      $searchForm = this.$el.find('form#search-form');
      data = Backbone.Syphon.serialize(this);
      return this.trigger('users:search', this.buildQuerySearch(data.search_term));
    };

    Users.prototype.buildQuerySearch = function(searchTerm) {
      return {
        q: {
          m: 'or',
          name_cont: searchTerm,
          email_cont: searchTerm
        }
      };
    };

    return Users;

  })(Marionette.CompositeView);
});
