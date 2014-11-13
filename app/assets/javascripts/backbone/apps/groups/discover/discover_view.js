// Generated by CoffeeScript 1.6.3
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.AlumNet.module('GroupsApp.Discover', function(Discover, AlumNet, Backbone, Marionette, $, _) {
  var _ref, _ref1, _ref2, _ref3;
  this.AlumNet = AlumNet;
  Discover.Layout = (function(_super) {
    __extends(Layout, _super);

    function Layout() {
      _ref = Layout.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Layout.prototype.template = 'groups/discover/templates/layout';

    Layout.prototype.className = 'container-fluid';

    Layout.prototype.regions = {
      header_region: '#groups-search-region',
      list_region: '#groups-list-region'
    };

    return Layout;

  })(Marionette.LayoutView);
  Discover.HeaderView = (function(_super) {
    __extends(HeaderView, _super);

    function HeaderView() {
      _ref1 = HeaderView.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    HeaderView.prototype.template = 'groups/discover/templates/groups_search';

    HeaderView.prototype.events = {
      'click .js-search': 'performSearch'
    };

    HeaderView.prototype.performSearch = function(e) {
      var data;
      e.preventDefault();
      data = Backbone.Syphon.serialize(this);
      return this.trigger('groups:search', this.buildQuerySearch(data.search_term));
    };

    HeaderView.prototype.buildQuerySearch = function(searchTerm) {
      return {
        q: {
          m: 'or',
          name_cont: searchTerm,
          description_cont: searchTerm
        }
      };
    };

    return HeaderView;

  })(Marionette.LayoutView);
  Discover.GroupView = (function(_super) {
    __extends(GroupView, _super);

    function GroupView() {
      _ref2 = GroupView.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    GroupView.prototype.template = 'groups/discover/templates/group';

    GroupView.prototype.className = 'col-md-4 col-sm-6 col-xs-12';

    GroupView.prototype.events = {
      'click .js-group': 'showGroup',
      'click .js-join': 'sendJoin',
      'mouseenter .group-image-container': 'showSubGroups',
      'mouseleave .group-image-container': 'hideSubGroups'
    };

    GroupView.prototype.sendJoin = function(e) {
      e.preventDefault();
      return this.trigger('join');
    };

    GroupView.prototype.showGroup = function(e) {
      e.preventDefault();
      return this.trigger('group:show');
    };

    GroupView.prototype.showSubGroups = function(e) {
      return this.$el.find('.group-image-container').children('.overlay-subgroups').fadeIn();
    };

    GroupView.prototype.hideSubGroups = function(e) {
      return this.$el.find('.group-image-container').children('.overlay-subgroups').fadeOut();
    };

    return GroupView;

  })(Marionette.ItemView);
  return Discover.GroupsView = (function(_super) {
    __extends(GroupsView, _super);

    function GroupsView() {
      _ref3 = GroupsView.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    GroupsView.prototype.className = 'ng-scope';

    GroupsView.prototype.idName = 'wrapper';

    GroupsView.prototype.template = 'groups/discover/templates/groups_container';

    GroupsView.prototype.childView = Discover.GroupView;

    GroupsView.prototype.childViewContainer = ".main-groups-area";

    return GroupsView;

  })(Marionette.CompositeView);
});
