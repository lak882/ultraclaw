// interclaw-chatbot/attachments.js — File upload, read, chips UI
(function(cc) {

  var FILE_MAX_BYTES = 100 * 1024; // 100 KB per file

  document.getElementById('chatbot-file-input').addEventListener('change', function(e) {
    var files = Array.from(e.target.files);
    files.forEach(function(file) {
      cc.attachedFiles.push(file);
    });
    cc.updateAttachmentUI();
    cc.updateSendButton();
    e.target.value = '';
  });

  cc.getFileIcon = function(filename) {
    var ext = (filename.split('.').pop() || '').toLowerCase();
    var imgExts = ['png','jpg','jpeg','gif','svg','webp','bmp'];
    var docExts = ['pdf','doc','docx','txt','md','rtf','csv'];
    if (imgExts.indexOf(ext) !== -1) return '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>';
    if (docExts.indexOf(ext) !== -1) return '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>';
    return '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V9z"/><polyline points="13 2 13 9 20 9"/></svg>';
  };

  cc.getFileLabel = function(filename) {
    var ext = (filename.split('.').pop() || '').toLowerCase();
    var labels = {png:'Image',jpg:'Image',jpeg:'Image',gif:'Image',svg:'Image',webp:'Image',pdf:'PDF',doc:'Document',docx:'Document',txt:'Text',md:'Markdown',csv:'CSV',hl7:'HL7'};
    return labels[ext] || 'File';
  };

  cc.updateAttachmentUI = function() {
    var container = document.getElementById('chatbot-attachments');
    var divider = document.getElementById('chatbot-attachments-divider');
    if (cc.attachedFiles.length === 0) {
      container.style.display = 'none';
      container.innerHTML = '';
      if (divider) divider.classList.remove('visible');
      return;
    }
    container.style.display = 'flex';
    if (divider) divider.classList.add('visible');
    container.innerHTML = cc.attachedFiles.map(function(f, i) {
      return '<div class="chatbot-attachment-chip">' +
        '<div class="chip-icon">' + cc.getFileIcon(f.name) + '</div>' +
        '<div class="chip-info">' +
          '<span class="chip-name">' + cc.escapeHtml(f.name) + '</span>' +
          '<span class="chip-label">' + cc.getFileLabel(f.name) + '</span>' +
        '</div>' +
        '<button class="chatbot-attachment-remove" onclick="removeAttachment(' + i + ')">&times;</button>' +
      '</div>';
    }).join('');
  };

  cc.removeAttachment = function(index) {
    cc.attachedFiles.splice(index, 1);
    cc.updateAttachmentUI();
    cc.updateSendButton();
  };

  cc.readFileWithTimeout = function(blob, timeout) {
    return Promise.race([
      blob.text(),
      new Promise(function(_, reject) {
        setTimeout(function() { reject(new Error('File read timed out after ' + (timeout / 1000) + 's')); }, timeout);
      })
    ]);
  };

  cc.uploadFileToServer = async function(file) {
    var formData = new FormData();
    formData.append('file', file);
    var resp = await fetch(cc.apiBase + '/api/upload', {
      method: 'POST',
      body: formData,
    });
    return await resp.json();
  };

  cc.readAttachedFiles = async function() {
    var FILE_READ_TIMEOUT = 5000;
    var parts = [];
    for (var i = 0; i < cc.attachedFiles.length; i++) {
      var file = cc.attachedFiles[i];
      var truncated = false;
      var content;
      try {
        var slice = file.size > FILE_MAX_BYTES ? file.slice(0, FILE_MAX_BYTES) : file;
        content = await cc.readFileWithTimeout(slice, FILE_READ_TIMEOUT);
        if (file.size > FILE_MAX_BYTES) {
          truncated = true;
        }
        var controlCount = 0;
        for (var c = 0; c < Math.min(content.length, 4096); c++) {
          var code = content.charCodeAt(c);
          if (code < 32 && code !== 9 && code !== 10 && code !== 13) controlCount++;
        }
        if (controlCount / Math.min(content.length, 4096) > 0.05) {
          try {
            var uploadResult = await cc.uploadFileToServer(file);
            if (uploadResult.success) {
              parts.push('--- File: ' + file.name + ' (binary, ' + file.size + ' bytes) ---\nServer path: ' + uploadResult.path);
            } else {
              parts.push('--- File: ' + file.name + ' (binary, ' + file.size + ' bytes) ---\n[Upload failed: ' + (uploadResult.error || 'Unknown error') + ']');
            }
          } catch (uploadErr) {
            parts.push('--- File: ' + file.name + ' (binary, ' + file.size + ' bytes) ---\n[Upload failed: ' + uploadErr.message + ']');
          }
          continue;
        }
        content = content.replace(/\0/g, '');
      } catch (err) {
        parts.push('--- File: ' + file.name + ' ---\n[Could not read file: ' + err.message + ']');
        continue;
      }
      var header = '--- File: ' + file.name + ' (' + file.size + ' bytes' + (truncated ? ', truncated to first 100KB' : '') + ') ---';
      parts.push(header + '\n' + content);
    }
    return parts.join('\n\n');
  };

})(window._cc);
