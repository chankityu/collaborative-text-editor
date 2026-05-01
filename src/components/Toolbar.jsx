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
