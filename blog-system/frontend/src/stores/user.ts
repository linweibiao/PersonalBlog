import { defineStore } from 'pinia'
import axios from 'axios'

// 创建axios实例
const api = axios.create({
  baseURL: 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json'
  },
  withCredentials: true
})
import router from '../router'

interface User {
  id: number
  username: string
  email?: string
  role: string
}

interface UserState {
  user: User | null
  token: string | null
  isLoggedIn: boolean
}

export const userStore = defineStore('user', {
  state: (): UserState => ({
    user: null,
    token: localStorage.getItem('token'),
    isLoggedIn: !!localStorage.getItem('token')
  }),
  
  actions: {
    async login(username: string, password: string) {
    try {
      console.log('开始登录请求...')
      // 发送登录请求
      const response = await api.post('/auth/login', { username, password }, {
        headers: {
          'Content-Type': 'application/json'
        },
        responseType: 'json'
      })
        
        console.log('登录响应状态:', response.status)
        console.log('登录响应数据:', response.data)
        
        // 验证响应数据
        if (!response.data || typeof response.data !== 'object') {
          console.error('登录失败: 响应数据格式错误')
          return { success: false, message: '登录失败: 服务器返回格式错误' }
        }
        
        // 解构响应数据，适配后端返回的字段名
        const { token, role, user_id, username: responseUsername } = response.data
        
        if (!token) {
          console.error('登录失败: 未返回token')
          return { success: false, message: '登录失败: 服务器未返回认证令牌' }
        }
        
        // 保存token和用户信息
        this.token = token
        this.user = {
          id: user_id || 1, // 使用后端返回的user_id
          username: responseUsername || username,
          role: role || 'user'
        }
        this.isLoggedIn = true
        
        // 存储到localStorage
        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(this.user))
        
        console.log('登录成功，用户信息已保存')
        return { success: true }
      } catch (error: any) {
        console.error('登录错误详情:', error)
        
        // 初始化错误消息
        let errorMessage = '登录失败，请重试'
        
        if (error.response) {
          console.error('错误响应状态:', error.response.status)
          
          // 针对不同错误类型提供具体信息
          if (error.response.status === 401) {
            errorMessage = '用户名或密码错误'
          } 
          // 检测HTML响应
          else if (typeof error.response.data === 'string' && error.response.data.startsWith('<!doctype html')) {
            console.error('检测到HTML响应而不是JSON')
            errorMessage = '登录失败: 服务器返回错误页面'
          }
          // 尝试提取JSON响应中的错误消息
          else if (error.response.data && typeof error.response.data === 'object') {
            if (error.response.data.message) {
              errorMessage = error.response.data.message
            }
          }
          // 其他HTTP错误
          else {
            errorMessage = `登录失败: HTTP ${error.response.status}`
          }
        } else if (error.request) {
          console.error('无响应:', error.request)
          errorMessage = '登录失败: 无法连接到服务器，请检查网络或服务器状态'
        } else {
          console.error('请求配置错误:', error.message)
          errorMessage = '登录失败: 网络请求配置错误'
        }
        
        console.error('最终错误信息:', errorMessage)
        return { 
          success: false, 
          message: errorMessage
        }
      }
    },
    
    async register(username: string, email: string, password: string) {
    try {
      console.log('开始注册请求...', { username, email });
      // 发送注册请求
      const response = await api.post('/auth/register', { username, email, password }, {
        headers: {
          'Content-Type': 'application/json'
        },
        responseType: 'json'
      })
      
      console.log('注册请求完成，状态码:', response.status);
        
      console.log('注册响应状态:', response.status)
      console.log('注册响应数据:', response.data)
      
      // 验证响应数据
      if (!response.data || typeof response.data !== 'object') {
        console.error('注册失败: 响应数据格式错误')
        return { success: false, message: '注册失败: 服务器返回格式错误' }
      }
      
      // 检查是否注册成功
      if (response.data.message && (response.data.message.includes('成功') || response.data.message.includes('success'))) {
        // 注册成功，自动保存token和用户信息
        if (response.data.token) {
          this.token = response.data.token;
          this.user = {
            id: response.data.user_id,
            username: response.data.username || username,
            email: email,
            role: response.data.role || 'user'
          };
          this.isLoggedIn = true;
          
          // 存储到localStorage
          localStorage.setItem('token', this.token);
          localStorage.setItem('user', JSON.stringify(this.user));
          
          console.log('注册成功并自动登录，用户信息已保存:', this.user);
        }
        return { success: true }
      } else if (response.data.message) {
        return { 
          success: false, 
          message: response.data.message
        }
      }
      
      return { success: true }
    } catch (error: any) {
      console.error('注册错误详情:', error);
      
      // 初始化错误消息
      let errorMessage = '注册失败，请重试';
      
      if (error.response) {
        console.error('错误响应状态:', error.response.status);
        console.error('错误响应数据:', error.response.data);
        
        // 提供更具体的错误信息
        if (error.response.data && error.response.data.message) {
          errorMessage = error.response.data.message;
        } else if (error.response.status === 400) {
          errorMessage = '请求参数错误，请检查输入';
        } else if (error.response.status === 409) {
          errorMessage = '用户名或邮箱已被使用';
        } else if (error.response.status >= 500) {
          errorMessage = '服务器错误，请稍后再试';
        }
        
        // 针对不同错误类型提供具体信息
        if (error.response.status === 400) {
          // 用户名或邮箱已存在
          errorMessage = error.response.data?.message || '用户名或邮箱已被使用'
        }
        // 检测HTML响应
        else if (typeof error.response.data === 'string' && error.response.data.startsWith('<!doctype html')) {
          console.error('检测到HTML响应而不是JSON')
          errorMessage = '注册失败: 服务器返回错误页面'
        }
        // 尝试提取JSON响应中的错误消息
        else if (error.response.data && typeof error.response.data === 'object') {
          if (error.response.data.message) {
            errorMessage = error.response.data.message
          }
        }
        // 其他HTTP错误
        else {
          errorMessage = `注册失败: HTTP ${error.response.status}`
        }
      } else if (error.request) {
        console.error('无响应:', error.request)
        errorMessage = '注册失败: 无法连接到服务器，请检查网络或服务器状态'
      } else {
        console.error('请求配置错误:', error.message)
        errorMessage = '注册失败: 网络请求配置错误'
      }
      
      console.error('最终错误信息:', errorMessage)
      return { 
        success: false, 
        message: errorMessage
      }
    }
    },
    
    logout() {
      // 清除状态
      this.token = null
      this.user = null
      this.isLoggedIn = false
      
      // 清除localStorage
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      
      // 跳转到登录页
      router.push('/login')
    },
    
    // 从localStorage恢复用户信息
    restoreUser() {
      console.log('===== 恢复用户信息 =====')
      
      // 首先检查token是否存在
      const token = localStorage.getItem('token')
      if (!token) {
        console.log('恢复用户信息: 未找到token，清除状态')
        // 直接清除状态，避免无限循环
        this.token = null
        this.user = null
        this.isLoggedIn = false
        return
      }
      
      // 设置token
      this.token = token
      
      // 恢复用户信息
      const userStr = localStorage.getItem('user')
      if (userStr) {
        try {
          const userData = JSON.parse(userStr)
          console.log('恢复用户信息: 从localStorage获取到用户数据:', userData)
          
          // 验证用户数据是否包含必要字段
          if (userData && typeof userData === 'object' && userData.id && userData.username) {
            // 确保角色字段存在，默认为'user'
            userData.role = userData.role || 'user'
            this.user = userData
            this.isLoggedIn = true
            console.log('恢复用户信息: 成功，用户角色:', this.user.role)
          } else {
            console.log('恢复用户信息: 用户数据格式无效，清除状态')
            // 直接清除状态，避免无限循环
            this.token = null
            this.user = null
            this.isLoggedIn = false
          }
        } catch (e) {
          console.error('恢复用户信息: 解析用户数据失败，清除状态:', e)
          // 直接清除状态，避免无限循环
          this.token = null
          this.user = null
          this.isLoggedIn = false
        }
      } else {
        console.log('恢复用户信息: 未找到用户数据，清除状态')
        // 直接清除状态，避免无限循环
        this.token = null
        this.user = null
        this.isLoggedIn = false
      }
      
      console.log('恢复用户信息: 完成，当前用户角色:', this.user?.role)
      console.log('========================')
    },
    
    // 更新用户角色
    async updateUserRole(userId: number, role: string) {
      try {
        // 设置请求头，添加Authorization令牌
        const headers = {
          Authorization: `Bearer ${this.token}`
        }
        
        // 发送API请求
        await api.put(`/admin/users/${userId}`, { role }, { headers })
        
        return { success: true }
      } catch (error) {
        console.error('更新用户角色失败:', error)
        throw error
      }
    },
    
    // 删除用户
    async deleteUser(userId: number) {
      try {
        // 设置请求头，添加Authorization令牌
        const headers = {
          Authorization: `Bearer ${this.token}`
        }
        
        // 发送API请求
        await api.delete(`/admin/users/${userId}`, { headers })
        
        return { success: true }
      } catch (error) {
        console.error('删除用户失败:', error)
        throw error
      }
    },
    
    // 删除文章
    async deleteArticle(articleId: number) {
      try {
        // 设置请求头，添加Authorization令牌
        const headers = {
          Authorization: `Bearer ${this.token}`
        }
        
        // 发送API请求
        await api.delete(`/articles/${articleId}`, { headers })
        
        return { success: true }
      } catch (error) {
        console.error('删除文章失败:', error)
        throw error
      }
    }
  }
})