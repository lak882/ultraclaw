// interclaw-chatbot/markdown.js — renderMarkdown, renderMarkdownWithQuickReplies, linkifyComponents
(function(cc) {

  // Infer editor type from a fully-qualified class name
  cc.inferEditorType = function(className) {
    var parts = className.split('.');
    var parent = parts.length >= 2 ? parts[parts.length - 2].toLowerCase() : '';
    var last = parts.length >= 1 ? parts[parts.length - 1].toLowerCase() : '';
    var lower = className.toLowerCase();
    // Check package folder AND last part for each type
    if (parent === 'dtl' || last === 'dtl') return 'dtl';
    if (parent === 'rule' || last === 'rule' || lower.endsWith('routingrule')) return 'rule';
    if (parent === 'bpl' || last === 'bpl') return 'bpl';
    if (lower.endsWith('.production') || lower.endsWith('production')) return 'production';
    // Common suffix heuristics for classes that don't follow Pkg.Type.Name convention
    if (last.endsWith('transform') || last.endsWith('passthrough')) return 'dtl';
    if (last.endsWith('process') || last.endsWith('dispatcher')) return 'bpl';
    // Production components (no dedicated editor — link to production config)
    if (parent === 'bs') return 'bs';
    if (parent === 'bo') return 'bo';
    if (parent === 'bp') return 'bp';
    if (parent === 'msg') return 'msg';
    if (last.endsWith('service')) return 'bs';
    if (last.endsWith('operation')) return 'bo';
    return null;
  };

  cc.linkifyComponents = function(html) {
    var isZen = !document.querySelector('app-root');
    var isChatMode = document.body.classList.contains('ic-chat-mode');
    return html.replace(/(?<![\/\w"=])(\b[A-Z][A-Za-z0-9]*(?:\.[A-Z][A-Za-z0-9]*){2,})\b(?!\.cls)(?![^<]*>)/g, function(m, cls) {
      var link = cc.buildPortalLink(cls);
      if (link) {
        var target = (isZen && !isChatMode) ? '' : ' target="_blank"';
        var onclick = (isZen && !isChatMode) ? ' onclick="var f=document.getElementById(\'viewer-frame\');if(f){f.src=this.href;return false;}"' : '';
        return '<a href="' + link.url + '"' + target + onclick + ' class="chatbot-link" title="' + link.label + '">' + cls + ' &#x2197;</a>';
      }
      return cls;
    });
  };

  // Configure marked.js renderer for chatbot CSS classes
  var chatbotRenderer = null;
  function getRenderer() {
    if (chatbotRenderer) return chatbotRenderer;
    chatbotRenderer = new marked.Renderer();
    chatbotRenderer.code = function(code, lang) {
      // marked 12.x passes an object {text, lang} as first arg
      if (typeof code === 'object') { lang = code.lang; code = code.text; }
      return '<pre class="chatbot-codeblock"><code>' + (code || '').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</code></pre>';
    };
    chatbotRenderer.codespan = function(text) {
      if (typeof text === 'object') text = text.text;
      return '<code class="chatbot-inline-code">' + text + '</code>';
    };
    chatbotRenderer.table = function(header, body) {
      // marked 12.x passes an object {header, rows}
      if (typeof header === 'object') {
        var t = header;
        var html = '<table class="chatbot-table"><thead><tr>';
        t.header.forEach(function(h) { html += '<th>' + h.text + '</th>'; });
        html += '</tr></thead><tbody>';
        t.rows.forEach(function(row) {
          html += '<tr>';
          row.forEach(function(c) { html += '<td>' + c.text + '</td>'; });
          html += '</tr>';
        });
        return html + '</tbody></table>';
      }
      return '<table class="chatbot-table"><thead>' + header + '</thead><tbody>' + body + '</tbody></table>';
    };
    chatbotRenderer.heading = function(text, level) {
      if (typeof text === 'object') { level = text.depth; text = text.text; }
      var tag = 'h' + (level + 1);
      return '<' + tag + ' class="chatbot-h">' + text + '</' + tag + '>';
    };
    chatbotRenderer.hr = function() { return '<hr class="chatbot-hr">'; };
    chatbotRenderer.blockquote = function(quote) {
      if (typeof quote === 'object') quote = quote.text;
      return '<blockquote class="chatbot-blockquote">' + quote + '</blockquote>';
    };
    chatbotRenderer.link = function(href, title, text) {
      if (typeof href === 'object') { text = href.text; title = href.title; href = href.href; }
      return '<a href="' + href + '" target="_blank" class="chatbot-link">' + text + '</a>';
    };
    chatbotRenderer.list = function(body, ordered) {
      // marked 12.x passes object {items, ordered, start}
      if (typeof body === 'object') {
        ordered = body.ordered;
        var itemsHtml = '';
        body.items.forEach(function(item) {
          itemsHtml += '<li>' + item.text + '</li>';
        });
        body = itemsHtml;
      }
      var tag = ordered ? 'ol' : 'ul';
      var cls = ordered ? 'chatbot-list-ordered' : 'chatbot-list';
      return '<' + tag + ' class="' + cls + '">' + body + '</' + tag + '>';
    };
    return chatbotRenderer;
  }

  cc.renderMarkdown = function(text) {
    // Strip SDK noise before rendering
    text = text.replace(/\[(?:View|Open) in Portal\]\([^)]+\)[ \t]*/gi, '');
    text = text.replace(/^PORTAL_URL:.*$/gm, '');
    text = text.replace(/^\/goto(?:-reload)?\s.*$/gm, '');
    text = text.replace(/^\/skill(?:-goto)?\s.*$/gm, '');
    text = text.replace(/^Token usage:.*$/gm, '');
    text = text.replace(/^Co-Authored-By:.*$/gm, '');
    text = text.replace(/\n{3,}/g, '\n\n');
    text = text.trim();

    var html;
    if (typeof marked !== 'undefined') {
      html = marked.parse(text, { breaks: true, gfm: true, renderer: getRenderer() });
    } else {
      // Fallback: basic escaping if marked hasn't loaded yet
      html = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br>');
    }

    // Add portal links for IRIS component class names
    html = cc.linkifyComponents(html);

    return html;
  };

  cc.renderMarkdownWithQuickReplies = function(text) {
    var parts = text.split(/:::quick_replies\n/);
    if (parts.length === 1) return cc.renderMarkdown(text);
    var html = cc.renderMarkdown(parts[0]).replace(/(<br\s*\/?>\s*)+$/, '');
    for (var i = 1; i < parts.length; i++) {
      var endIdx = parts[i].indexOf('\n:::');
      if (endIdx === -1) {
        html += cc.renderMarkdown(parts[i]);
      } else {
        var jsonStr = parts[i].substring(0, endIdx);
        var rest = parts[i].substring(endIdx + 4);
        try {
          var replies = JSON.parse(jsonStr);
          html += '<div class="quick-replies">';
          for (var ri = 0; ri < replies.length; ri++) {
            html += '<button class="quick-reply-btn" onclick="sendQuickReply(this.textContent)">' + cc.escapeHtml(replies[ri]) + '</button>';
          }
          html += '</div>';
        } catch(e) {
          html += cc.renderMarkdown(jsonStr);
        }
        if (rest.trim()) html += cc.renderMarkdown(rest);
      }
    }
    return html;
  };

})(window._cc);
