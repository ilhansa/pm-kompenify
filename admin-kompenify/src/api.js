import axios from 'axios';

const api = axios.create({
    // Membaca url dari file .env
    baseURL: import.meta.env.VITE_API_BASE_URL ??  'http://127.0.0.1:8000/api', 
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Bypass halaman warning ngrok
        'ngrok-skip-browser-warning': 'true' 
    },
    validateStatus: function (status) {
        return status >= 200 && status < 300; 
    }
});

// Interceptor Token Authorization
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => {
    return Promise.reject(error);
});

export default api;