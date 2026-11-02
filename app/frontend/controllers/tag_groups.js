// JavaScript version of tag_groups.coffee
// Part of the CoffeeScript to JavaScript migration

// Add remove tags in a TagGroup
myApp.controller('TagGroupsController', ['$scope', '$window', '$http', '$rootScope', function($scope, $window, $http, $rootScope) {
  $scope.tags = $window.bonsai.tags;
  $scope.selected_tags = [];
  $scope.edit = false;

  $scope.win = $window;

  // Set up edit mode
  const setEdit = function() {
    $scope.title = 'Edit tag group';
    $scope.edit = true;
    $scope.id = $window.tag_group.id;
    $scope.name = $window.tag_group.name;

    $scope.selected_tags = _.where($scope.tags, function(tag) {
      return _.include($window.tag_group.tag_ids, tag.id);
    });

    _.each($scope.tags, function(tag) {
      if (_.include($window.tag_group.tag_ids, tag.id)) {
        tag.hide = true;
      }
    });
  };

  // Start set for edit
  if ($window.tag_group && $window.tag_group.id) {
    setEdit();
  } else {
    $scope.title = 'New tag group';
  }
  // End of set for edit

  $scope.color = Plugins.Tag.textColor;

  // Select a tag
  $scope.select = function(tg) {
    $scope.selected_tags.push(tg);
    tg.hide = true;
  };

  // Remove a tag
  $scope.remove = function(t, index) {
    $scope.selected_tags.splice(index, 1);
    const tag = _.find($scope.tags, function(tg) { 
      return t.id === tg.id; 
    });

    tag.hide = false;
  };

  // Get tag IDs
  const tagIds = function() {
    return _.map($scope.selected_tags, function(tag) { 
      return tag.id; 
    });
  };

  // Get data for API calls
  const getData = function() {
    return {
      name: $scope.name,
      tag_ids: tagIds()
    };
  };

  // Create new tag group
  const create = function() {
    $scope.submit = true;
    $http.post("/tag_groups", { tag_group: getData() })
    .success(function(resp) {
      $scope.submit = false;
      $window.history.pushState({resp: resp}, "Tag groups", `/tag_groups/${resp.id}/edit`);
      $scope.title = 'Edit tag group';

      $('#tag-group-button').notify('Created successfully.',
        {className: 'success', position: 'right', autoHideDelay: 3000});
    })
    .error(function(resp) {
      $scope.submit = false;
      $('#tag-group-button').notify('There was an error, please try again.',
        {className: 'error', position: 'right', autoHideDelay: 3000});
    });
  };

  // Update existing tag group
  const update = function() {
    $scope.submit = true;
    $http.put(`/tag_groups/${$scope.id}`, { tag_group: getData() })
    .success(function(resp) {
      $scope.submit = false;
      $('#tag-group-button').notify('Updated successfully.',
        {className: 'success', position: 'right', autoHideDelay: 3000});
    })
    .error(function(resp) {
      $scope.submit = false;
      $('#tag-group-button').notify('There was an error, please try again.',
        {className: 'error', position: 'right', autoHideDelay: 3000});
    });
  };

  // Save tag group
  $scope.save = function() {
    if ($scope.edit) {
      update();
    } else {
      create();
    }
  };

  // Listen for new tags
  $rootScope.$on('newTag', function(event, tag) {
    $scope.tags.push(tag);
  });

  // Listen for updated tags
  $rootScope.$on('updatedTag', function(event, tag) {
    const ind = _.findIndex($scope.tags, function(tg) { 
      return tg.id === tag.id; 
    });
    $scope.tags[ind].name = tag.name;
    $scope.tags[ind].label = tag.label;
    $scope.tags[ind].bgcolor = tag.bgcolor;
  });
}]);
