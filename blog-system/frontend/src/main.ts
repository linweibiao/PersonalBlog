// 应用入口文件
// 初始化Vue应用，配置插件和中间件

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import App from './App.vue'
import router from './router'
import axios from 'axios'
import { userStore } from './stores/user'

// 创建应用实例
const app = createApp(App)

// 配置Axios
// 使用相对路径，让请求通过vite代理转发到后端
axios.defaults.baseURL = ''
axios.interceptors.request.use(config => {
  // 请求拦截器：为所有请求添加Authorization令牌
  // 从localStorage获取token
  const token = localStorage.getItem('token')
  // 如果token存在，且不是OPTIONS请求，添加到请求头
  // OPTIONS请求是浏览器预检请求，不应该包含认证头
  if (token && config.method !== 'OPTIONS') {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// 将axios挂载到app上，避免导入问题
app.config.globalProperties.$axios = axios

// 注册插件
app.use(createPinia())  // 注册Pinia状态管理
app.use(router)  // 注册Vue Router路由
app.use(ElementPlus)  // 注册Element Plus UI组件库

// 恢复用户登录状态
userStore().restoreUser()

// 挂载应用到DOM
app.mount('#app')