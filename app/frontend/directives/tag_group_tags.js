// JavaScript version of tag_group_tags.coffee
// Part of the CoffeeScript to JavaScript migration

myApp.directive('tagGroupSelect', ['$window', function($window) {
  return {
    restrict: 'E',
    transclude: true,
    link: function($scope, $element, $attrs) {
      const tags_hash = $window.bonsai.tags_hash;
      $scope.selectedTags = [];

      const findTagGroup = function(id) {
        return $window.tag_groups.filter(function(tg) {
          return tg.id === id;
        })[0];
      };

      const selectTags = function(tag_ids) {
        $scope.selectedTags = [];

        tag_ids.forEach(function(id) {
          if (tags_hash[id]) {
            $scope.selectedTags.push(tags_hash[id]);
          }
        });
      };

      const changeTags = function(tg_id) {
        const tagGroup = findTagGroup(tg_id);
        selectTags(tagGroup.tag_ids);
      };

      const $sel = $element.find('select').on('change', function() {
        const val = $sel.val();

        if (val !== '') {
          const numVal = parseInt(val);
          changeTags(numVal);
        } else {
          $scope.selectedTags = [];
        }

        $scope.$apply();
      });

      if ($sel.val() !== '') {
        const val = parseInt($sel.val());
        changeTags(val);
      }

      $scope.color = Plugins.Tag.textColor;
    },
    
    template: 
      '<span ng-transclude></span>' +
      '<div class="tags-for">' +
      '  <span ng-repeat="tag in selectedTags" class="tag" style="background:{{ tag.bgcolor }};color: {{ color(tag.bgcolor) }}">' +
      '    {{ tag.name }}' +
      '  </span>' +
      '</div>'
  };
}]);
