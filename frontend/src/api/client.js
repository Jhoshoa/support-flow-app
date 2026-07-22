import axios from 'axios'

const apiClient = axios.create({
  baseURL: '/api/v1',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

apiClient.interceptors.response.use(
  response => response,
  error => {
    const message = error.response?.data?.error || 'An unexpected error occurred'
    const details = error.response?.data?.details || []
    return Promise.reject({ message, details, status: error.response?.status })
  }
)

export default apiClient
