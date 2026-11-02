// JavaScript version of attachment.coffee
// Part of the CoffeeScript to JavaScript migration

const AttachmentController = function($scope, $http, $timeout, $upload) {
  $scope.imageFor = function(attachment) {
    if (attachment.image) {
      return attachment.small_attachment_url;
    } else {
      return _b.getExtnameImage(attachment.name);
    }
  };

  // Move attachment position up
  $scope.upPosition = function(index) {
    const tmp = $scope.attachments[index - 1];
    if (!tmp) return;

    const att = $scope.attachments[index];
    $http.put(`/attachments/${att.id}`, { attachment: {move: 'up', position: tmp.position} })
    .success(function(resp) {
      att.position = tmp.position;
      tmp.position = att.position;
      $scope.attachments[index - 1] = att;
      $scope.attachments[index] = tmp;
    });
  };

  // Move attachment position down
  $scope.downPosition = function(index) {
    const tmp = $scope.attachments[index + 1];
    if (!tmp) return;

    const att = $scope.attachments[index];
    $http.put(`/attachments/${att.id}`, { attachment: {move: 'down', position: tmp.position} })
    .success(function(resp) {
      att.position = tmp.position;
      tmp.position = att.position;
      $scope.attachments[index + 1] = att;
      $scope.attachments[index] = tmp;
    });
  };

  // Delete attachment
  $scope.delete = function(attch, index) {
    if (attch.process) return;

    if (confirm('Are you sure you want to delete the attachment?')) {
      attch.process = true;

      $http.delete(`/attachments/${attch.id}`)
      .success(function() {
        $scope.attachments.splice(index, 1);
      })
      .error(function() {
        alert('There was an error deleting the attachment');
      })
      .finally(function() {
        attch.process = false;
      });
    }
  };

  // UPLOAD
  $scope.fileReaderSupported = window.FileReader !== null || (window.FileAPI === null || FileAPI.html5 !== false);
  
  // Upload files
  $scope.onFileSelect = function($files) {
    $scope.selectedFiles = [];

    let pos = 0;
    const l = $scope.attachments.length;
    try {
      pos = $scope.attachments[l - 1].position;
    } catch (e) {
      pos = 0;
    }

    $files.forEach(function(file, index) {
      $scope.selectedFiles.push({file: file, index: index, progress: 0, dataUrl: false});
      const sel = $scope.selectedFiles[index];

      if ($scope.fileReaderSupported && file.type.indexOf('image') > -1) {
        const fileReader = new FileReader();
        fileReader.readAsDataURL(file);

        (function(fileReader, index) {
          fileReader.onload = function(event) {
            $timeout(function() {
              sel.dataUrl = event.target.result;
            });
          };
        })(fileReader, index);
      }
    });

    $files.forEach(function(file, index) {
      pos = pos + 1;
      console.log(pos, $scope.attachments.length);
      $scope.upload = $upload.upload({
        url: '/attachments',
        data: {
          attachable_id: $scope.attachable_id,
          attachable_type: $scope.attachable_type,
          position: pos
        },
        file: file
      })
      .progress(function(event) {
        const f = $scope.selectedFiles[index];
        f.progress = Math.round((event.loaded / event.total) * 100);
      })
      .success(function(data, status, headers, config) {
        $scope.attachments.push(data);
      })
      .finally(function() {
        $scope.selectedFiles[index].terminated = true;
      });
    });
  };
};

AttachmentController.$inject = ['$scope', '$http', '$timeout', '$upload'];

myApp.controller('AttachmentController', AttachmentController);
