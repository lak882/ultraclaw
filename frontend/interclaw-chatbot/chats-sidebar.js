// chats-sidebar.js — Left-side chat history sidebar (ChatGPT-style).
// Milestone 1: UI only, backed by in-memory stub data. Persistence lands in M2/M3.
(function(cc) {
  'use strict';

  // ── SVG icons ───────────────────────────────────────────────────────────
  // Writing icon (Lucide "square-pen"): notepad with a pencil overlay — same
  // affordance ChatGPT/Claude use for "start a new chat".
  var ICON_NEW_CHAT = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.375 2.625a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4Z"/></svg>';
  var ICON_COLLAPSE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/></svg>';
  var ICON_EXPAND = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/></svg>';
  var ICON_EDIT = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>';
  var ICON_DELETE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/></svg>';
  var ICON_SEARCH = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>';
  // Filled star for the active-favorite state, outline for the toggle button
  var ICON_STAR_FILLED = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>';
  var ICON_STAR_OUTLINE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01z"/></svg>';

  // ── Chat store (M2/M3: server-backed CRUD) ──────────────────────────────
  // Shape: { chats: [{id,title,updatedAt}], activeId, user }
  // List is hydrated via GET /api/chats; full message history is fetched
  // on demand via GET /api/chats/:id. M3: PUT /api/chats/:id persists
  // on every turn (debounced) and on rename; DELETE /api/chats/:id removes.
  cc.chatsStore = cc.chatsStore || { chats: [], activeId: null, user: null };
  cc.chatsSearchQuery = cc.chatsSearchQuery || '';

  function chatsUrl(suffix) {
    return (cc.chatApiBase || '/api/interclaw/production') + '/api/chats' + (suffix || '');
  }

  cc.refreshChatsList = function() {
    return fetch(chatsUrl(), { credentials: 'same-origin' })
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) {
        if (!data) return;
        cc.chatsStore.chats = data.chats || [];
        cc.chatsStore.user = data.user || null;
        cc.renderChatsSidebar();
      })
      .catch(function(err) { console.warn('[interclaw] chats list failed:', err); });
  };

  // ── Persistence (M3) ────────────────────────────────────────────────────
  // The chat id == cc.sessionId (set by the 'session' event from the
  // backend on the first turn). Before we have a session, we have no id
  // yet, so the very first prompt can't be persisted — the backend's
  // session_id arrives mid-stream and the next saveState catches it.
  function serializeCurrentPane() {
    var out = [];
    var content = document.getElementById('chatbot-content');
    if (!content) return out;
    var children = content.children;
    for (var i = 0; i < children.length; i++) {
      var el = children[i];
      var msgEl = el.classList && el.classList.contains('chatbot-msg-wrap')
        ? el.querySelector('.chatbot-message') : el;
      if (!msgEl || !msgEl.classList) continue;
      var type = 'assistant';
      if (msgEl.classList.contains('chatbot-message-user')) type = 'user';
      else if (msgEl.classList.contains('chatbot-message-system')) type = 'system';
      else if (msgEl.classList.contains('chatbot-message-error')) type = 'error';
      else if (msgEl.classList.contains('chatbot-message-tool')) type = 'tool';
      out.push({ type: type, html: msgEl.innerHTML });
    }
    return out;
  }

  function deriveTitle(messages) {
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].type !== 'user') continue;
      var tmp = document.createElement('div');
      tmp.innerHTML = messages[i].html || '';
      var text = (tmp.textContent || '').trim();
      if (!text) continue;
      if (text.charAt(0) === '/') {
        var parts = text.split(/\s+/);
        parts.shift();
        text = parts.join(' ').trim();
        if (!text) continue;
      }
      if (text.length > 60) {
        var cut = text.substring(0, 60);
        var sp = cut.lastIndexOf(' ');
        if (sp >= 40) cut = cut.substring(0, sp);
        text = cut + '...';
      }
      return text;
    }
    return 'Untitled';
  }

  function upsertChat(entry) {
    var chats = cc.chatsStore.chats || (cc.chatsStore.chats = []);
    for (var i = 0; i < chats.length; i++) {
      if (chats[i].id === entry.id) { chats[i] = entry; return; }
    }
    chats.push(entry);
  }

  var _persistTimer = null;
  cc.persistChat = function() {
    if (!cc.sessionId) return;
    if (_persistTimer) clearTimeout(_persistTimer);
    _persistTimer = setTimeout(function() {
      _persistTimer = null;
      var messages = serializeCurrentPane();
      if (!messages.length) return;
      var chat = (cc.chatsStore.chats || []).filter(function(c) { return c.id === cc.sessionId; })[0];
      var body = { messages: messages };
      if (!chat || !chat.title || chat.title === 'Untitled') {
        body.title = deriveTitle(messages);
      }
      fetch(chatsUrl('/' + encodeURIComponent(cc.sessionId)), {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify(body)
      })
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(data) {
        if (!data) return;
        cc.chatsStore.activeId = data.id;
        upsertChat({ id: data.id, title: data.title || 'Untitled', updatedAt: data.updatedAt || Date.now() });
        cc.renderChatsSidebar();
      })
      .catch(function(err) { console.warn('[interclaw] persistChat failed:', err); });
    }, 500);
  };

  // Wrap saveState so every DOM change triggers a debounced server PUT.
  // Guard against double-wrapping if the module is re-evaluated.
  if (cc.saveState && !cc.saveState._m3Wrapped) {
    var _origSaveState = cc.saveState;
    cc.saveState = function() {
      var r = _origSaveState.apply(this, arguments);
      try { cc.persistChat(); } catch (e) { console.warn('[interclaw] persistChat threw:', e); }
      return r;
    };
    cc.saveState._m3Wrapped = true;
  }

  // ── DOM construction ────────────────────────────────────────────────────
  function buildSidebar() {
    if (document.getElementById('ic-chats-sidebar')) return;

    var sidebar = document.createElement('aside');
    sidebar.id = 'ic-chats-sidebar';
    sidebar.innerHTML =
      '<div class="ic-chats-header">' +
        '<span class="ic-chats-brand">Chats</span>' +
        '<button class="ic-chats-collapse-btn" id="ic-chats-collapse" title="Hide chats" aria-label="Hide chats">' + ICON_COLLAPSE + '</button>' +
      '</div>' +
      '<a class="ic-chats-new" id="ic-chats-new" role="button" tabindex="0">' +
        '<span class="ic-chats-new-icon">' + ICON_NEW_CHAT + '</span>' +
        '<span class="ic-chats-new-label">New chat</span>' +
      '</a>' +
      '<div class="ic-chats-search">' +
        '<span class="ic-chats-search-icon">' + ICON_SEARCH + '</span>' +
        '<input type="search" id="ic-chats-search-input" class="ic-chats-search-input" placeholder="Search chats" autocomplete="off" spellcheck="false">' +
      '</div>' +
      '<div class="ic-chats-list" id="ic-chats-list"></div>';
    document.body.appendChild(sidebar);

    // Floating reopen pill sits outside the sidebar so it stays visible
    // when the rail is hidden.
    var reopenBtn = document.createElement('button');
    reopenBtn.id = 'ic-chats-reopen';
    reopenBtn.title = 'Show chats';
    reopenBtn.setAttribute('aria-label', 'Show chats');
    reopenBtn.innerHTML = ICON_EXPAND;
    document.body.appendChild(reopenBtn);

    // ── Event wiring ──────────────────────────────────────────────────────
    document.getElementById('ic-chats-new').addEventListener('click', cc.startNewChat);
    document.getElementById('ic-chats-collapse').addEventListener('click', function() {
      document.body.classList.add('ic-chats-collapsed');
      try { localStorage.setItem('ic-chats-collapsed', '1'); } catch (e) {}
    });
    reopenBtn.addEventListener('click', function() {
      document.body.classList.remove('ic-chats-collapsed');
      try { localStorage.removeItem('ic-chats-collapsed'); } catch (e) {}
    });

    // Live search: filter in-place on input; Esc clears.
    var searchInput = document.getElementById('ic-chats-search-input');
    searchInput.addEventListener('input', function() {
      cc.chatsSearchQuery = searchInput.value || '';
      cc.renderChatsSidebar();
    });
    searchInput.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        searchInput.value = '';
        cc.chatsSearchQuery = '';
        cc.renderChatsSidebar();
        searchInput.blur();
      }
    });

    // Restore collapsed state from the previous session.
    try {
      if (localStorage.getItem('ic-chats-collapsed') === '1') {
        document.body.classList.add('ic-chats-collapsed');
      }
    } catch (e) {}

    cc.renderChatsSidebar();
    cc.refreshChatsList();
  }

  // ── Grouping by recency ─────────────────────────────────────────────────
  function groupLabel(ts) {
    var now = Date.now();
    var day = 1000 * 60 * 60 * 24;
    var age = now - ts;
    if (age < day) return 'Today';
    if (age < day * 2) return 'Yesterday';
    if (age < day * 7) return 'Previous 7 Days';
    if (age < day * 30) return 'Previous 30 Days';
    var d = new Date(ts);
    return d.toLocaleString('en-US', { month: 'long', year: 'numeric' });
  }

  // ── Render ──────────────────────────────────────────────────────────────
  cc.renderChatsSidebar = function() {
    var list = document.getElementById('ic-chats-list');
    if (!list) return;

    var chats = (cc.chatsStore.chats || []).slice().sort(function(a, b) {
      return (b.updatedAt || 0) - (a.updatedAt || 0);
    });

    // Apply the live search filter (case-insensitive substring match on title).
    var q = (cc.chatsSearchQuery || '').trim().toLowerCase();
    if (q) {
      chats = chats.filter(function(c) {
        return (c.title || '').toLowerCase().indexOf(q) !== -1;
      });
    }

    if (!chats.length) {
      list.innerHTML = '<div class="ic-chats-empty">' +
        (q ? 'No chats match "' + escapeHtml(q) + '".'
           : 'No chats yet. Start a new one to see it here.') + '</div>';
      return;
    }

    // Split into Favorites and Recents. Drag between sections or click the
    // star on a row to toggle the flag.
    var favorites = [];
    var recents = [];
    for (var i = 0; i < chats.length; i++) {
      if (chats[i].favorite) favorites.push(chats[i]);
      else recents.push(chats[i]);
    }

    function renderRow(c) {
      var active = c.id === cc.chatsStore.activeId ? ' active' : '';
      var starIcon = c.favorite ? ICON_STAR_FILLED : ICON_STAR_OUTLINE;
      var starTitle = c.favorite ? 'Unfavorite' : 'Favorite';
      return '<div class="ic-chats-item' + active + '" data-chat-id="' + escapeHtml(c.id) +
                   '" data-favorite="' + (c.favorite ? 'true' : 'false') + '" draggable="true">' +
                '<span class="ic-chats-item-title">' + escapeHtml(c.title || 'Untitled') + '</span>' +
                '<span class="ic-chats-item-actions">' +
                  '<button class="ic-chats-item-action ic-chats-item-star' + (c.favorite ? ' is-active' : '') +
                         '" data-action="favorite" title="' + starTitle + '" aria-label="' + starTitle + '">' + starIcon + '</button>' +
                  '<button class="ic-chats-item-action" data-action="rename" title="Rename" aria-label="Rename">' + ICON_EDIT + '</button>' +
                  '<button class="ic-chats-item-action" data-action="delete" title="Delete" aria-label="Delete">' + ICON_DELETE + '</button>' +
                '</span>' +
              '</div>';
    }

    // Always render both group headers so drag-to-favorite has a drop target
    // even when one of the groups is empty.
    var html = '';
    html += '<div class="ic-chats-group-label" data-group="favorites">Favorites</div>';
    if (favorites.length) {
      for (var j = 0; j < favorites.length; j++) html += renderRow(favorites[j]);
    } else {
      html += '<div class="ic-chats-group-empty">Star a chat or drag it here.</div>';
    }
    html += '<div class="ic-chats-group-label" data-group="recents">Recents</div>';
    if (recents.length) {
      for (var k = 0; k < recents.length; k++) html += renderRow(recents[k]);
    }
    list.innerHTML = html;

    // Click delegation
    list.onclick = function(e) {
      var actionBtn = e.target.closest('.ic-chats-item-action');
      var item = e.target.closest('.ic-chats-item');
      if (!item) return;
      var id = item.getAttribute('data-chat-id');
      if (actionBtn) {
        e.stopPropagation();
        var action = actionBtn.getAttribute('data-action');
        if (action === 'rename') cc.renameChatInline(id, item);
        else if (action === 'delete') cc.deleteChat(id);
        else if (action === 'favorite') {
          var chat = (cc.chatsStore.chats || []).filter(function(c) { return c.id === id; })[0];
          cc.setChatFavorite(id, chat ? !chat.favorite : true);
        }
        return;
      }
      cc.openChat(id);
    };

    // Drag-and-drop wiring for favorite toggling.
    // Drop an item onto (or anywhere inside) a section header / below the
    // other section's items to toggle its favorite flag.
    var sidebar = document.getElementById('ic-chats-sidebar');
    var draggedId = null;

    list.querySelectorAll('.ic-chats-item').forEach(function(el) {
      el.addEventListener('dragstart', function(e) {
        draggedId = el.getAttribute('data-chat-id');
        el.classList.add('ic-dragging');
        if (sidebar) sidebar.classList.add('ic-dragging');
        try {
          e.dataTransfer.effectAllowed = 'move';
          e.dataTransfer.setData('text/plain', draggedId || '');
        } catch (_) {}
      });
      el.addEventListener('dragend', function() {
        el.classList.remove('ic-dragging');
        if (sidebar) sidebar.classList.remove('ic-dragging');
        list.querySelectorAll('.ic-chats-group-label.ic-drop-target').forEach(function(l) {
          l.classList.remove('ic-drop-target');
        });
        draggedId = null;
      });
    });

    // Use the whole list as the drop surface; highlight whichever group
    // label is nearest on move, and resolve to that group on drop.
    function groupFromPoint(y) {
      var labels = list.querySelectorAll('.ic-chats-group-label');
      var active = null;
      for (var i2 = 0; i2 < labels.length; i2++) {
        if (labels[i2].getBoundingClientRect().top <= y) active = labels[i2];
      }
      return active;
    }

    list.addEventListener('dragover', function(e) {
      if (!draggedId) return;
      e.preventDefault();
      try { e.dataTransfer.dropEffect = 'move'; } catch (_) {}
      var target = groupFromPoint(e.clientY);
      list.querySelectorAll('.ic-chats-group-label').forEach(function(l) {
        l.classList.toggle('ic-drop-target', l === target);
      });
    });

    list.addEventListener('drop', function(e) {
      if (!draggedId) return;
      e.preventDefault();
      var target = groupFromPoint(e.clientY);
      var group = target ? target.getAttribute('data-group') : null;
      var id = draggedId;
      draggedId = null;
      if (!group) return;
      cc.setChatFavorite(id, group === 'favorites');
    });
  };

  // ── Favorite toggle — optimistic update + server PUT ────────────────────
  cc.setChatFavorite = function(id, favorite) {
    var chat = (cc.chatsStore.chats || []).filter(function(c) { return c.id === id; })[0];
    if (!chat) return;
    if (!!chat.favorite === !!favorite) return;   // no-op drag onto same group
    chat.favorite = !!favorite;
    cc.renderChatsSidebar();
    fetch(chatsUrl('/' + encodeURIComponent(id)), {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'same-origin',
      body: JSON.stringify({ favorite: !!favorite })
    })
    .then(function(r) { if (!r.ok) console.warn('[interclaw] favorite PUT failed:', r.status); })
    .catch(function(err) { console.warn('[interclaw] favorite toggle failed:', err); });
  };

  // ── Actions ─────────────────────────────────────────────────────────────
  cc.startNewChat = function() {
    cc.chatsStore.activeId = null;
    cc.sessionId = null;
    cc.sessionReady = false;
    clearMessagesPane();
    cc.renderChatsSidebar();
    try {
      if (typeof sessionStorage !== 'undefined') sessionStorage.removeItem('chatbot-state');
    } catch (e) {}
  };

  // Roadmap: remember the Management Portal URL (or active component) that
  // was open when each chat was last saved, and restore it when the chat is
  // reopened. Requires: (a) ChatStore.Put accepting a `portalUrl` or
  // `activeComponent` field — already merge-friendly, so just add to the
  // payload in persistChat(); (b) openChat() below, after rehydrating
  // messages, calls cc.navigateLegacyUi(chat.portalUrl) if set. Keep the
  // restore best-effort: if the referenced component no longer exists, fall
  // back to Production Config.
  cc.openChat = function(id) {
    cc.chatsStore.activeId = id;
    cc.renderChatsSidebar();
    fetch(chatsUrl('/' + encodeURIComponent(id)), { credentials: 'same-origin' })
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(chat) {
        if (!chat || !chat.messages) return;
        clearMessagesPane();
        rehydrateMessages(chat.messages);
        // Adopt the chat id as the active session so /api/start sends
        // the right session_id AND subsequent saveState PUTs hit the
        // same file instead of creating a new one.
        cc.sessionId = chat.id;
        cc.sessionReady = true;
      })
      .catch(function(err) { console.warn('[interclaw] openChat failed:', err); });
  };

  function clearMessagesPane() {
    var content = document.getElementById('chatbot-content');
    if (content) content.innerHTML = '';
  }

  // Rebuild message bubbles from the stored {type, html} array. Matches the
  // DOM structure produced by cc.addMessage / cc.saveState.
  function rehydrateMessages(messages) {
    var content = document.getElementById('chatbot-content');
    if (!content) return;
    messages.forEach(function(m) {
      var msg = document.createElement('div');
      msg.className = 'chatbot-message';
      if (m.type === 'user') msg.className += ' chatbot-message-user';
      else if (m.type === 'system') msg.className += ' chatbot-message-system';
      else if (m.type === 'error') msg.className += ' chatbot-message-error';
      else if (m.type === 'tool') msg.className += ' chatbot-message-tool';
      msg.innerHTML = m.html || '';
      if (m.type === 'user' || m.type === 'assistant') {
        var wrap = document.createElement('div');
        wrap.className = 'chatbot-msg-wrap' + (m.type === 'user' ? ' chatbot-msg-wrap--user' : '');
        wrap.appendChild(msg);
        content.appendChild(wrap);
      } else {
        content.appendChild(msg);
      }
    });
    content.scrollTop = content.scrollHeight;
  }

  cc.renameChatInline = function(id, itemEl) {
    var titleEl = itemEl.querySelector('.ic-chats-item-title');
    if (!titleEl) return;
    titleEl.setAttribute('contenteditable', 'true');
    titleEl.focus();
    // Select all
    var range = document.createRange();
    range.selectNodeContents(titleEl);
    var sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(range);

    var finish = function(commit) {
      titleEl.removeAttribute('contenteditable');
      titleEl.removeEventListener('blur', onBlur);
      titleEl.removeEventListener('keydown', onKey);
      if (commit) {
        var newTitle = titleEl.textContent.trim();
        var chat = findChat(id);
        if (chat && newTitle && newTitle !== chat.title) {
          chat.title = newTitle;
          chat.updatedAt = Date.now();
          fetch(chatsUrl('/' + encodeURIComponent(id)), {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'same-origin',
            body: JSON.stringify({ title: newTitle })
          })
          .then(function(r) { if (!r.ok) console.warn('[interclaw] rename PUT failed:', r.status); })
          .catch(function(err) { console.warn('[interclaw] rename failed:', err); });
        }
      }
      cc.renderChatsSidebar();
    };
    var onBlur = function() { finish(true); };
    var onKey = function(e) {
      if (e.key === 'Enter') { e.preventDefault(); finish(true); }
      else if (e.key === 'Escape') { e.preventDefault(); finish(false); }
    };
    titleEl.addEventListener('blur', onBlur);
    titleEl.addEventListener('keydown', onKey);
  };

  cc.deleteChat = function(id) {
    var chat = findChat(id);
    if (!chat) return;
    if (!window.confirm('Delete "' + chat.title + '"?')) return;
    fetch(chatsUrl('/' + encodeURIComponent(id)), {
      method: 'DELETE',
      credentials: 'same-origin'
    })
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(data) {
      if (!data || !data.deleted) {
        console.warn('[interclaw] delete failed — server returned:', data);
        return;
      }
      cc.chatsStore.chats = cc.chatsStore.chats.filter(function(c) { return c.id !== id; });
      if (cc.chatsStore.activeId === id) {
        cc.chatsStore.activeId = null;
        cc.sessionId = null;
        cc.sessionReady = false;
        clearMessagesPane();
        try { sessionStorage.removeItem('chatbot-state'); } catch (e) {}
      }
      cc.renderChatsSidebar();
    })
    .catch(function(err) { console.warn('[interclaw] delete failed:', err); });
  };

  function findChat(id) {
    return (cc.chatsStore.chats || []).find(function(c) { return c.id === id; });
  }

  function escapeHtml(s) {
    var d = document.createElement('div');
    d.textContent = s == null ? '' : String(s);
    return d.innerHTML;
  }

  // ── Bootstrap ───────────────────────────────────────────────────────────
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', buildSidebar);
  } else {
    buildSidebar();
  }

})(window._cc);
