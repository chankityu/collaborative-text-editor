# Collaborative Real-Time Text Editor

A high-performance, feature-rich collaborative text editor built with **React**, **Tiptap (ProseMirror)**, and **Yjs**. This application supports multi-user editing with real-time cursor tracking, versioning, and a review/commenting system.

## 🚀 Features

- **Real-Time Collaboration**: Edit documents simultaneously with other users using CRDT-based synchronization.
- **Cursor Tracking**: View the live cursor positions and names of all active collaborators.
- **Rich Text Formatting**:
  - Basic styles: Bold, Italic, Paragraphs.
  - Lists: Ordered and Bulleted lists.
  - Styling: Text color and highlight support.
- **Word & Character Count**: Real-time statistics displayed in the editor status bar.
- **Review & Commenting**:
  - Highlight text for review.
  - Add comments to specific sections of the document.
- **Version History**: Save snapshots of your progress and restore previous versions from the history archive.
- **Persistence**: Automatic local storage saving ensures you never lose your work between sessions.
- **Clear Document**: One-click functionality to reset the editor canvas.

## 🛠️ Tech Stack

- **Framework**: React 18
- **Editor Engine**: [Tiptap](https://tiptap.dev/) (built on ProseMirror)
- **Collaboration Logic**: [Yjs](https://yjs.dev/)
- **Communication Provider**: [y-webrtc](https://github.com/yjs/y-webrtc) (No server configuration required for demo)
- **Icons**: Lucide React
- **Build Tool**: Vite

## 📸 Screenshots

<!-- INSERT_SCREENSHOT_HERE -->
![Editor Overview](https://via.placeholder.com/800x450.png?text=Placeholder:+Insert+Your+Editor+Screenshot+Here)
*Example: Real-time editing with multiple user cursors and the sidebar active.*

## 📦 Installation

### Prerequisites
- **Node.js**: Version 18.0.0 or higher
- **npm** or **yarn**

### Setup
1. Clone the repository:
   ```bash
   git clone <your-github-repo-link>
   cd collaborative-text-editor
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

4. Open the application:
   Navigate to `http://localhost:5173` in your browser. To test collaboration, open the same link in a private/incognito window or a different browser.

## 📝 License

This project is licensed under the MIT License.

---
**GitHub Repository**: Link to Repository
