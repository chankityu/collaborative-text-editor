#!/bin/bash

# Create directory structure
mkdir -p src/components src/styles

# Create package.json
cat <<EOF > package.json
{
  "name": "collaborative-text-editor",
  "private": true,
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@tiptap/extension-character-count": "^2.1.13",
    "@tiptap/extension-collaboration": "^2.1.13",
    "@tiptap/extension-collaboration-cursor": "^2.1.13",
    "@tiptap/extension-color": "^2.1.13",
    "@tiptap/extension-highlight": "^2.1.13",
    "@tiptap/extension-text-style": "^2.1.13",
    "@tiptap/pm": "^2.1.13",
    "@tiptap/react": "^2.1.13",
    "@tiptap/starter-kit": "^2.1.13",
    "lucide-react": "^0.294.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "y-webrtc": "^10.3.0",
    "yjs": "^13.6.10"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.0",
    "vite": "^5.0.0"
  }
}
EOF

# Create vite.config.js
cat <<EOF > vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  plugins: [react()],
})
EOF

# Create index.html
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Collaborative Editor</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Create main.jsx
cat <<EOF > src/main.jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './styles/editor.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
EOF

# Create App.jsx
cat <<EOF > src/App.jsx
import React from 'react';
import Editor from './components/Editor';

function App() {
  return (
    <div className="App">
      <header className="app-header">
        <h1>Real-time Collaborative Editor</h1>
      </header>
      <Editor />
    </div>
  );
}
export default App;
EOF

# Create Editor.jsx (The Core Logic)
cat <<EOF > src/components/Editor.jsx
import React, { useState, useEffect, useCallback } from 'react';
import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Collaboration from '@tiptap/extension-collaboration';
import CollaborationCursor from '@tiptap/extension-collaboration-cursor';
import CharacterCount from '@tiptap/extension-character-count';
import Highlight from '@tiptap/extension-highlight';
import Color from '@tiptap/extension-color';
import TextStyle from '@tiptap/extension-text-style';
import * as Y from 'yjs';
import { WebrtcProvider } from 'y-webrtc';
import Toolbar from './Toolbar';

const colors = ['#958DF1', '#F98181', '#FBBC88', '#FAF594', '#70C2B4'];
const names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Edward'];
const randomUser = {
  name: names[Math.floor(Math.random() * names.length)],
  color: colors[Math.floor(Math.random() * colors.length)],
};

const Editor = () => {
  const [ydoc] = useState(() => new Y.Doc());
  const [provider] = useState(() => new WebrtcProvider('collaborative-room-xyz', ydoc));
  const [history, setHistory] = useState(() => JSON.parse(localStorage.getItem('editor-history') || '[]'));
  const [comments, setComments] = useState(() => JSON.parse(localStorage.getItem('editor-comments') || '[]'));

  const editor = useEditor({
    extensions: [
      StarterKit.configure({ history: false }),
      Collaboration.configure({ document: ydoc }),
      CollaborationCursor.configure({ provider, user: randomUser }),
      CharacterCount,
      TextStyle,
      Color,
      Highlight.configure({ multicolor: true }),
    ],
    content: localStorage.getItem('editor-content') || '<p>Start typing...</p>',
    onUpdate: ({ editor }) => {
      localStorage.setItem('editor-content', editor.getHTML());
    },
  });

  const saveVersion = () => {
    const newVersion = { id: Date.now(), date: new Date().toLocaleString(), content: editor.getHTML() };
    const updatedHistory = [newVersion, ...history];
    setHistory(updatedHistory);
    localStorage.setItem('editor-history', JSON.stringify(updatedHistory));
  };

  const addComment = () => {
    const text = window.prompt("Add a comment:");
    if (text) {
      const newComment = { id: Date.now(), text, user: randomUser.name };
      const updatedComments = [...comments, newComment];
      setComments(updatedComments);
      localStorage.setItem('editor-comments', JSON.stringify(updatedComments));
      // In a full implementation, we would wrap the selected text in a mark
      editor.chain().focus().setHighlight({ color: '#ffcc00' }).run();
    }
  };

  if (!editor) return null;

  return (
    <div className="editor-wrapper">
      <Toolbar editor={editor} onSave={saveVersion} onAddComment={addComment} />

      <div className="main-layout">
        <div className="editor-side">
          <div className="stats-bar">
            Words: {editor.storage.characterCount.words()} | Characters: {editor.storage.characterCount.characters()}
          </div>
          <EditorContent editor={editor} className="tiptap-container" />
        </div>

        <div className="sidebar">
          <section>
            <h3>Review/Comments</h3>
            {comments.map(c => (
              <div key={c.id} className="comment-card">
                <strong>{c.user}:</strong> {c.text}
              </div>
            ))}
          </section>
          <hr />
          <section>
            <h3>History</h3>
            {history.map(v => (
              <button key={v.id} onClick={() => editor.commands.setContent(v.content)} className="history-btn">
                {v.date}
              </button>
            ))}
          </section>
        </div>
      </div>
    </div>
  );
};
export default Editor;
EOF

# Create Toolbar.jsx
cat <<EOF > src/components/Toolbar.jsx
import React from 'react';
import { Bold, Italic, List, ListOrdered, Trash2, Save, MessageSquare, Type } from 'lucide-react';

const Toolbar = ({ editor, onSave, onAddComment }) => {
  if (!editor) return null;

  return (
    <div className="toolbar">
      <button onClick={() => editor.chain().focus().toggleBold().run()} className={editor.isActive('bold') ? 'is-active' : ''}>
        <Bold size={18} />
      </button>
      <button onClick={() => editor.chain().focus().toggleItalic().run()} className={editor.isActive('italic') ? 'is-active' : ''}>
        <Italic size={18} />
      </button>
      <button onClick={() => editor.chain().focus().toggleBulletList().run()} className={editor.isActive('bulletList') ? 'is-active' : ''}>
        <List size={18} />
      </button>
      <button onClick={() => editor.chain().focus().toggleOrderedList().run()} className={editor.isActive('orderedList') ? 'is-active' : ''}>
        <ListOrdered size={18} />
      </button>
      <input
        type="color"
        onInput={e => editor.chain().focus().setColor(e.target.value).run()}
        value={editor.getAttributes('textStyle').color || '#000000'}
      />
      <button onClick={() => editor.chain().focus().toggleHighlight({ color: '#70C2B4' }).run()}>
        Review
      </button>
      <button onClick={onAddComment}>
        <MessageSquare size={18} />
      </button>
      <button onClick={onSave} className="save-btn">
        <Save size={18} /> Save Version
      </button>
      <button onClick={() => editor.commands.clearContent()} className="clear-btn">
        <Trash2 size={18} /> Clear
      </button>
    </div>
  );
};
export default Toolbar;
EOF

# Create editor.css
cat <<EOF > src/styles/editor.css
:root { --primary: #6366f1; --bg: #f8fafc; }
body { margin: 0; font-family: -apple-system, sans-serif; background: var(--bg); }
.app-header { background: #fff; padding: 1rem; border-bottom: 1px solid #ddd; text-align: center; }
.editor-wrapper { max-width: 1200px; margin: 2rem auto; display: flex; flex-direction: column; gap: 1rem; }
.toolbar { display: flex; gap: 0.5rem; background: #fff; padding: 0.75rem; border-radius: 8px; border: 1px solid #ddd; flex-wrap: wrap; }
.toolbar button { padding: 0.5rem; border: 1px solid #eee; background: white; cursor: pointer; border-radius: 4px; display: flex; align-items: center; }
.toolbar button.is-active { background: #e0e7ff; border-color: var(--primary); color: var(--primary); }
.main-layout { display: grid; grid-template-columns: 1fr 300px; gap: 1.5rem; }
.tiptap-container { background: #fff; min-height: 500px; border: 1px solid #ddd; border-radius: 8px; padding: 2rem; outline: none; }
.sidebar { background: #fff; padding: 1rem; border-radius: 8px; border: 1px solid #ddd; height: fit-content; }
.comment-card { background: #fef9c3; padding: 0.5rem; margin-bottom: 0.5rem; border-radius: 4px; font-size: 0.9rem; border: 1px solid #fde047; }
.history-btn { display: block; width: 100%; text-align: left; padding: 0.5rem; margin-bottom: 0.4rem; background: #f1f5f9; border: none; cursor: pointer; border-radius: 4px; }
.stats-bar { padding-bottom: 0.5rem; font-size: 0.85rem; color: #64748b; }

/* Collaboration Cursors */
.collaboration-cursor__caret { border-left: 2px solid; border-right: 2px solid; margin-left: -1px; margin-right: -1px; pointer-events: none; position: relative; }
.collaboration-cursor__label { border-radius: 3px 3px 3px 0; color: #fff; font-size: 12px; font-style: normal; font-weight: 600; left: -1px; line-height: normal; padding: 0.1rem 0.3rem; position: absolute; top: -1.4em; user-select: none; white-space: nowrap; }
EOF

echo "Project structure created successfully!"
echo "Run: npm install && npm run dev"

