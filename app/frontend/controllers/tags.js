// JavaScript version of tags.coffee
// Part of the CoffeeScript to JavaScript migration

// Main controller that applies edits and creates tags
const TagsController = function($scope, $element, $http, $timeout, $window, $rootScope) {
  $scope.tags = $window.bonsai.tags;
  $scope.editorBtn = 'Crear';
  $scope.tag_name = '';

  // Init
  $scope.colors = ['#FF0000', '#FF9000', '#FFD300', '#77B92D', '#049CDB', '#1253A6', '#4022A7', '#8E129F'];
  $scope.tag_bgcolor = '#ffffff';
  $scope.errors = {};

  $scope.disableApply = function() {
    return $('input.row-check:checked').length === 0;
  };

  // Detect changes on tags
  $('body').on('click', 'input.row-check', function() {
    $scope.disableApply();
    $scope.$apply();
    return true;
  });

  // error css @val required to watch the attribute
  $scope.errorCssFor = function(val, key) {
    return $scope.errors[key] != null ? 'field_with_errors' : '';
  };

  // Marks the checked or unchecks a tag
  $scope.markChecked = function(tag) {
    tag.checked = !tag.checked;
  };

  // Checks if any
  $scope.tagsAny = function(prop, value) {
    return _.any($scope.tags, function(tag) { return tag[prop] === value; });
  };

  // text color for a tag, this is a function
  $scope.color = Plugins.Tag.textColor;

  // Functions to filter tags
  $scope.filter = function() {
    $window.location = [$scope.url, $scope.createTagFilterParams()].join("?");
  };

  $scope.selectedTags = function() {
    return _.select($scope.tags, function(tag) { return tag.checked; });
  };

  $scope.createTagFilterParams = function() {
    return _.map($scope.selectedTags(), function(tag) { return `tag_ids[]=${tag.id}`; }).join("&");
  };
  // End of functions to filter tags

  // Closes the editor modal
  $scope.closeModal = function() {
    if ($scope.editing) {
      $scope.tags[$scope.currentIndex] = $scope.oldTag;
    } else {
      $scope.tags.pop();
    }

    $scope.editor.modal('hide');
    return false;
  };

  // Marks the selected tags
  $scope.markTags = function() {
    _.each($scope.tags, function(tag) {
      if (_.include($scope.tagIds, tag.id)) tag.checked = true;
    });
  };
  $scope.markTags(); // Initial mark tag

  // Sets the color for tag_bgcolor, can't use tag_bgcolor=color
  $scope.setColor = function(color) {
    $scope.tag_bgcolor = color;
    $scope.$colorEditor.minicolors('value', color);
    return false;
  };

  // Apply selected tags of the selected rows
  $scope.applyTags = function() {
    const $but = $scope.editor.find('.apply-tags');
    $but.prop('disabled', true);

    const ids = _.map($('input.row-check:checked'), function(el) { return el.id; });
    const tag_ids = _($scope.tags).select(function(tag) { return tag.checked; })
      .map('id').value();
    const data = { tag_ids: tag_ids, ids: ids, model: $scope.model };

    $http({method: 'PATCH', url: '/tags/update_models', data: data})
    .success(function(data, status) {
      $scope.setListTags(ids, tag_ids);
      $element.notify('Se aplico las etiquetas correctamente', {position: 'top', className: 'success'});
    })
    .error(function(data, status) {
      $scope.showSaveErrors(data, status);
      $element.notify('Existio un error al aplicar las etiquetas', {position: 'top', className: 'error'});
    })
    .finally(function() {
      $but.prop('disabled', true);
    });
  };

  // Updates the tags for each item on a list
  $scope.setListTags = function(ids, tag_ids) {
    const tags = Plugins.Tag.getTagsById(tag_ids);
    _(ids).each(function(id) {
      const sel = `tagsfor[id='${id}']`;
      const scope = $(sel).isolateScope();
      scope.tags = tags;
      //scope.$apply();
    });
  };

  ////////////////////////////////////////
  // Operations to create edit tags
  // Saves the selectedTag

  // Create a new tag
  $scope.newTag = function() {
    $scope.errors = [];
    $scope.editing = false;
    $scope.tag_bgcolor = '#FF9000';
    $scope.tag_name = '';
    $scope.editorBtn = 'Crear';

    $scope.$colorEditor.minicolors('value', '#FF9000');
    $scope.editor.dialog('option', 'title', 'Nueva etiqueta');
    $scope.editor.dialog('open');
    return false;
  };

  // Edit tags available
  $scope.editTag = function(tag, index) {
    $scope.errors = [];
    $scope.currentIndex = index;
    $scope.editing = true;
    // ng-disabled directive not working
    $scope.editor.find('button').prop('disabled', false);
    $scope.tag_id = tag.id;
    $scope.tag_name = tag.name;
    $scope.tag_bgcolor = tag.bgcolor;
    $scope.editorBtn = 'Actualizar';

    $scope.$colorEditor.minicolors('value', tag.bgcolor);
    $scope.editor.dialog('option', 'title', 'Editar etiqueta');
    $scope.editor.dialog('open');
    return false;
  };

  $scope.save = function() {
    $scope.errors = {};
    if (!$scope.valid()) return;

    $scope.editor.find('button').prop('disabled', true);

    if ($scope.editing) {
      $scope.update();
    } else {
      $scope.create();
    }
  };

  // Updates a tag
  $scope.update = function() {
    $http({method: 'PATCH', url: '/tags/' + $scope.tag_id, data: $scope.getFormData()})
    .success(function(data, status) {
      const color = Plugins.Tag.textColor(data.bgcolor);
      const tag = { name: data.name, bgcolor: data.bgcolor, id: data.id, color: color };

      $scope.tags[$scope.currentIndex] = tag;
      $scope.editor.dialog('close');

      // Set global tags_hash variable
      $window.bonsai.tags_hash[data.id] = { name: data.name, label: data.name, bgcolor: data.bgcolor, id: data.id };
      $window.bonsai.tags.push({ name: data.name, label: data.name, bgcolor: data.bgcolor, id: data.id });
      // Update all related
      const sel = `.tag${data.id}`;
      $(sel).text(data.name).css({background: data.bgcolor, color: color});
    })
    .error(function(data, status) {
      $scope.showSaveErrors(data, status);
    })
    .finally(function() {
      $scope.editor.find('button').prop('disabled', false);
    });
  };

  // Creates new tag
  const tagsDiv = $('.tags-div');
  $scope.create = function() {
    $http.post('/tags', $scope.getFormData())
    .success(function(data, status) {
      $scope.tags.push({ name: data.name, bgcolor: data.bgcolor, id: data.id });
      // Set global tags_hash variable
      const tag = { name: data.name, label: data.name, bgcolor: data.bgcolor, id: data.id };
      $window.bonsai.tags_hash[data.id] = tag;
      $rootScope.$emit('newHash', tag);

      $timeout(function() {
        tagsDiv.scrollTo(tagsDiv.height() + 400);
      }, 30);
      $scope.editor.dialog('close');
    })
    .error(function(data, status) {
      $scope.showSaveErrors(data, status);
    })
    .finally(function() {
      $scope.editor.find('button').prop('disabled', false);
    });
  };

  // Validation
  $scope.valid = function() {
    if (!$scope.tag_name.match(/^[a-z\d\s\u00E0-\u00FC-]+$/i)) {
      $scope.errors['tag_name'] = 'Ingrese letras con espacio o números';
      $('#tag-name-input').notify($scope.errors['tag_name'], {position: 'top left', className: 'error'});
    }

    return !_.any($scope.errors);
  };

  // notify
  $scope.showSaveErrors = function(data, status) {
    if (status < 500) {
      if (data.errors.name) {
        $scope.errors['tag_name'] = data.errors.name.join(', ');
        $scope.editor.find('#tag-name-input')
          .notify($scope.errors['tag_name'], {className: 'error', positon: 'top center'});
      }
    } else {
      $scope.editor.parents('div:first')
        .notify('Existió un error al crear', {className: 'error', positon: 'top center'});
    }
  };

  $scope.getFormData = function() {
    return {tag: {name: $scope.tag_name, bgcolor: $scope.tag_bgcolor}};
  };
};

// End of function
TagsController.$inject = ['$scope', '$element', '$http', '$timeout', '$window', '$rootScope'];
myApp.controller('TagsController', TagsController);
