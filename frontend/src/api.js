import axios from "axios";
import { ACCESS_TOKEN } from "./constants";

const api = axios.create({
  baseURL: "http://127.0.0.1:8000",
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true,
  //withCredentials: false,  // ⬅️ disable for JWT-based auth
});

// JWT Token interceptor (your original logic)
api.interceptors.request.use(
  (config) => {
    // Debug logging
    console.log("📤 Axios Request:", config.method?.toUpperCase(), config.url);
    
    // Add JWT token if available
    const token = localStorage.getItem(ACCESS_TOKEN);
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
      console.log("🔑 Added JWT token to request");
    } else {
      console.log("⚠️ No JWT token found in localStorage");
    }
    
    return config;
  },
  (error) => {
    console.error("📤 Request Error:", error);
    return Promise.reject(error);
  }
);

// Response interceptor (debugging)
api.interceptors.response.use(
  (response) => {
    console.log("📥 Axios Response:", response.status, response.config.url);
    return response;
  },
  (error) => {
    console.error("📥 Response Error:", error.response?.status, error.config?.url);
    return Promise.reject(error);
  }
);

export default api;