import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

// Remove default margins and padding
document.body.style.margin = '0'
document.body.style.padding = '0'
document.documentElement.style.margin = '0'
document.documentElement.style.padding = '0'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
