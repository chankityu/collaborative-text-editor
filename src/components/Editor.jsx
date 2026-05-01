import React, { useState } from 'react';
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

// Initialize Yjs doc and provider outside the component to ensure they are singletons.
// This prevents the "Room already exists" error caused by React Strict Mode re-renders.
const ydoc = new Y.Doc();
const provider = new WebrtcProvider('collaborative-room-xyz', ydoc);

const Editor = () => {
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
