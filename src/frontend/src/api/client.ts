import axios from 'axios';

// Detect if running in Codespaces and construct API URL appropriately
const getAPIBaseURL = (): string => {
  if (import.meta.env.VITE_API_BASE_URL) {
    return import.meta.env.VITE_API_BASE_URL;
  }

  // In Codespaces, port forwarding uses subdomain format
  if (window.location.hostname.includes('github.dev') || window.location.hostname.includes('codespaces')) {
    const protocol = window.location.protocol;
    // Replace the frontend port (5173) with backend port (5230) in the subdomain
    const backendHostname = window.location.hostname.replace('-5173.', '-5230.');
    return `${protocol}//${backendHostname}`;
  }

  // Default to localhost for local development
  return 'http://localhost:5000';
};

const API_BASE_URL = getAPIBaseURL();

export const api = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for auth tokens (when implemented)
api.interceptors.request.use(
  config => {
    // Add auth token here if needed
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  response => response,
  error => {
    // Handle errors globally
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

export default api;
