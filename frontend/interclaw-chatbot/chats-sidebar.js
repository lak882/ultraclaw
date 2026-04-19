// chats-sidebar.js — Left-side chat history sidebar (ChatGPT-style).
// Milestone 1: UI only, backed by in-memory stub data. Persistence lands in M2/M3.
(function(cc) {
  'use strict';

  // ── SVG icons ───────────────────────────────────────────────────────────
  var ICON_NEW_CHAT = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg>';
  var ICON_COLLAPSE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/></svg>';
  var ICON_EXPAND = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="18" x="3" y="3" rx="2"/><path d="M9 3v18"/></svg>';
  var ICON_EDIT = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>';
  var ICON_DELETE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/></svg>';

  // ── In-memory stub (M1 only — replaced by server-backed store in M2) ────
  cc.chatsStore = cc.chatsStore || {
    chats: [
      { id: 'stub-1', title: 'Slim the toolbar border', updatedAt: Date.now() - 1000 * 60 * 30 },
      { id: 'stub-2', title: 'Fix SMP iframe fit', updatedAt: Date.now() - 1000 * 60 * 60 * 3 },
      { id: 'stub-3', title: 'Frontend dead-code cleanup', updatedAt: Date.now() - 1000 * 60 * 60 * 24 * 2 },
      { id: 'stub-4', title: 'Sanford POC test run 3', updatedAt: Date.now() - 1000 * 60 * 60 * 24 * 6 }
    ],
    activeId: null
  };

  // ── DOM construction ────────────────────────────────────────────────────
  function buildSidebar() {
    if (document.getElementById('ic-chats-sidebar')) return;

    var sidebar = document.createElement('aside');
    sidebar.id = 'ic-chats-sidebar';
    sidebar.innerHTML =
      '<div class="ic-chats-header">' +
        '<span class="ic-chats-brand">Chats</span>' +
        '<button class="ic-chats-collapse-btn" id="ic-chats-collapse" title="Hide chats">' + ICON_COLLAPSE + '</button>' +
      '</div>' +
      '<button class="ic-chats-new" id="ic-chats-new">' + ICON_NEW_CHAT + '<span>New chat</span></button>' +
      '<div class="ic-chats-list" id="ic-chats-list"></div>';
    document.body.appendChild(sidebar);

    var reopenBtn = document.createElement('button');
    reopenBtn.id = 'ic-chats-reopen';
    reopenBtn.title = 'Show chats';
    reopenBtn.innerHTML = ICON_EXPAND;
    document.body.appendChild(reopenBtn);

    // ── Event wiring ──────────────────────────────────────────────────────
    document.getElementById('ic-chats-collapse').addEventListener('click', function() {
      document.body.classList.add('ic-chats-collapsed');
      try { localStorage.setItem('ic-chats-collapsed', '1'); } catch (e) {}
    });
    reopenBtn.addEventListener('click', function() {
      document.body.classList.remove('ic-chats-collapsed');
      try { localStorage.removeItem('ic-chats-collapsed'); } catch (e) {}
    });
    document.getElementById('ic-chats-new').addEventListener('click', cc.startNewChat);

    // Restore collapsed state
    try {
      if (localStorage.getItem('ic-chats-collapsed') === '1') {
        document.body.classList.add('ic-chats-collapsed');
      }
    } catch (e) {}

    cc.renderChatsSidebar();
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

    if (!chats.length) {
      list.innerHTML = '<div class="ic-chats-empty">No chats yet. Start a new one to see it here.</div>';
      return;
    }

    var html = '';
    var lastGroup = null;
    for (var i = 0; i < chats.length; i++) {
      var c = chats[i];
      var grp = groupLabel(c.updatedAt || Date.now());
      if (grp !== lastGroup) {
        html += '<div class="ic-chats-group-label">' + escapeHtml(grp) + '</div>';
        lastGroup = grp;
      }
      var active = c.id === cc.chatsStore.activeId ? ' active' : '';
      html += '<div class="ic-chats-item' + active + '" data-chat-id="' + escapeHtml(c.id) + '">' +
                '<span class="ic-chats-item-title">' + escapeHtml(c.title || 'Untitled') + '</span>' +
                '<span class="ic-chats-item-actions">' +
                  '<button class="ic-chats-item-action" data-action="rename" title="Rename">' + ICON_EDIT + '</button>' +
                  '<button class="ic-chats-item-action" data-action="delete" title="Delete">' + ICON_DELETE + '</button>' +
                '</span>' +
              '</div>';
    }
    list.innerHTML = html;

    // Event delegation
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
        return;
      }
      cc.openChat(id);
    };
  };

  // ── Actions (M1 stubs; wired up to real store in M2/M3) ─────────────────
  cc.startNewChat = function() {
    var id = 'local-' + Date.now();
    cc.chatsStore.chats.unshift({ id: id, title: 'New chat', updatedAt: Date.now() });
    cc.chatsStore.activeId = id;
    cc.renderChatsSidebar();
    // In M2, the real implementation will also clear the messages pane and start a new session.
    // For M1, just signal intent via a system message so the user sees something happened.
    try { cc.addMessage && cc.addMessage('system', 'New chat started'); } catch (e) {}
  };

  cc.openChat = function(id) {
    cc.chatsStore.activeId = id;
    cc.renderChatsSidebar();
    // M1: display a system message so the click is visibly acknowledged.
    // In M2, this will call GET /api/chats/:id and rehydrate the conversation.
    var chat = findChat(id);
    try { cc.addMessage && cc.addMessage('system', 'Opened: ' + (chat ? chat.title : id)); } catch (e) {}
  };

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
        if (chat && newTitle) {
          chat.title = newTitle;
          chat.updatedAt = Date.now();
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
    cc.chatsStore.chats = cc.chatsStore.chats.filter(function(c) { return c.id !== id; });
    if (cc.chatsStore.activeId === id) cc.chatsStore.activeId = null;
    cc.renderChatsSidebar();
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
