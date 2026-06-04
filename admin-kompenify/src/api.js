import axios from 'axios';

const api = axios.create({
    baseURL: 'http://127.0.0.1:8000/api',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
    // Memaksa Axios menganggap status 200-300 murni sukses tanpa rewel masalah preflight
    validateStatus: function (status) {
        return status >= 200 && status < 300; 
    }
});

// Otomatis tempelkan token keamanan di setiap tembakan API
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