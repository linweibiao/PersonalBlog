<template>
  <div id="app">
    <el-container>
      <el-header>
        <div class="header-container">
          <!-- Logo和标题 -->
          <div class="header-left">
            <a href="/" class="logo">
              <span class="logo-text">个人博客系统</span>
            </a>
          </div>
          
          <!-- 导航链接和用户信息 -->
          <div class="header-right">
            <nav class="nav-tabs">
              <router-link to="/" class="nav-tab" active-class="active">首页</router-link>
              <router-link to="/articles" class="nav-tab" active-class="active">文章列表</router-link>
              <template v-if="isLoggedIn">
                <router-link to="/article/create" class="nav-tab" active-class="active">写文章</router-link>
                <template v-if="user?.role === 'admin'">
                  <router-link to="/admin" class="nav-tab admin-tab" active-class="active">管理后台</router-link>
                </template>
                <router-link to="/profile" class="nav-tab user-info-tab">{{ user?.username }}</router-link>
                <button class="logout-btn" @click="logout">退出登录</button>
              </template>
              <template v-else>
                <router-link to="/login" class="nav-tab" active-class="active">登录</router-link>
                <router-link to="/register" class="nav-tab register-btn" active-class="active">注册</router-link>
              </template>
            </nav>
          </div>
        </div>
      </el-header>
      
      <el-main>
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </el-main>
      
      <el-footer>
        <p>© 2024 个人博客系统 - 基于Python+Vue3开发</p>
      </el-footer>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { storeToRefs } from 'pinia'
import { userStore } from './stores/user'

// 获取用户登录状态
const store = userStore()
const { isLoggedIn, user } = storeToRefs(store)
const { logout } = store

// 恢复用户状态
store.restoreUser()
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  background-color: #f5f7fa;
}

#app {
  min-height: 100vh;
}

/* 自定义滚动条 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
}

::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* 页面过渡动画 */
.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

/* 主色调定义 - 调整为更简洁的配色 */
:root {
  --primary-color: #333;
  --secondary-color: #666;
  --accent-color: #007bff;
  --success-color: #28a745;
  --warning-color: #ffc107;
  --danger-color: #dc3545;
  --light-color: #f8f9fa;
  --dark-color: #343a40;
  --border-color: #dee2e6;
  --background-color: #f5f7fa;
  --text-primary: #303133;
  --text-regular: #606266;
  --text-secondary: #909399;
  --box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  --hover-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* 头部样式 - 简化设计 */
.el-header {
  background: #fff;
  border-bottom: 2px solid var(--border-color);
  padding: 0;
  height: 60px;
  line-height: 60px;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.header-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* 头部左右布局 */
.header-left {
  display: flex;
  align-items: center;
}

.header-right {
  display: flex;
  align-items: center;
}

/*  Logo样式 - 简化设计 */
.logo {
  font-size: 20px;
  font-weight: 800;
  color: var(--dark-color);
  margin: 0;
  text-decoration: none;
  transition: all 0.3s ease;
  display: inline-block;
}

.logo:hover {
  color: var(--accent-color);
}

/* Logo文字样式 */
.logo-text {
  font-size: 20px;
  font-weight: 800;
  color: var(--dark-color);
  transition: all 0.3s ease;
  letter-spacing: 0.5px;
}

.logo:hover .logo-text {
  color: var(--accent-color);
}

/* 导航样式 - 水平标签页设计 */
.nav-tabs {
  display: flex;
  gap: 0;
  align-items: center;
  background: transparent;
}

/* 导航标签样式 */
.nav-tab {
  color: var(--secondary-color);
  text-decoration: none;
  padding: 0 20px;
  height: 60px;
  line-height: 60px;
  transition: all 0.3s ease;
  cursor: pointer;
  font-weight: 500;
  font-size: 14px;
  border: none;
  background: transparent;
  display: inline-block;
  position: relative;
}

.nav-tab:hover {
  color: var(--accent-color);
  background: rgba(0, 123, 255, 0.05);
}

.nav-tab.active {
  color: var(--accent-color);
  font-weight: 600;
  background: transparent;
  border-bottom: 3px solid var(--accent-color);
}

/* 特殊标签样式 */
.admin-tab {
  color: var(--warning-color);
}

.admin-tab:hover {
  color: var(--warning-color);
  background: rgba(255, 193, 7, 0.05);
}

.admin-tab.active {
  color: var(--warning-color);
  border-bottom-color: var(--warning-color);
}

/* 用户信息标签 */
.user-info-tab {
  color: var(--secondary-color);
  font-weight: 500;
  display: inline-block;
  height: 60px;
  line-height: 60px;
  padding: 0 20px;
  transition: all 0.3s ease;
  cursor: default;
}

.user-info-tab:hover {
  color: var(--accent-color);
  background: rgba(0, 123, 255, 0.05);
}

/* 按钮样式 - 醒目的设计 */
.logout-btn {
  color: #fff;
  background: var(--danger-color);
  border: none;
  padding: 0 16px;
  border-radius: 0;
  transition: all 0.3s ease;
  cursor: pointer;
  font-weight: 500;
  font-size: 14px;
  margin-left: 0;
  height: 60px;
  line-height: 60px;
  display: inline-block;
}

.logout-btn:hover {
  background: #c82333;
  transform: translateY(-1px);
  box-shadow: var(--hover-shadow);
}

/* 注册按钮 - 醒目设计 */
.register-btn {
  color: #fff;
  background: var(--accent-color);
  padding: 0 20px;
  border-radius: 0;
}

.register-btn:hover {
  background: #0056b3;
  color: #fff;
}

.register-btn.active {
  background: #0056b3;
  border-bottom-color: #0056b3;
}

/* 移除不再需要的样式 */
.el-dropdown-menu,
.el-dropdown-item,
.el-dropdown-item.divided {
  display: none;
}

/* 修复路由链接样式 */
.router-link {
  text-decoration: none;
}

.router-link-exact-active {
  color: var(--accent-color);
  font-weight: 600;
  border-bottom: 3px solid var(--accent-color);
}

/* 响应式设计调整 */
@media (max-width: 768px) {
  .header-container {
    padding: 0 10px;
  }
  
  .logo {
    font-size: 16px;
  }
  
  .nav-tabs {
    gap: 0;
  }
  
  .nav-tab {
    padding: 0 12px;
    font-size: 13px;
  }
  
  .logout-btn {
    padding: 6px 12px;
    font-size: 13px;
    margin-left: 5px;
  }
  
  .el-main {
    padding: 20px 15px;
  }
}

/* 移除不再需要的下拉菜单样式 */
.el-dropdown-menu,
.el-dropdown-item,
.el-dropdown-item.divided {
  display: none;
}

/* 主内容区域 */
.el-main {
  padding: 40px 0;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  background: transparent;
}

/* 底部样式 */
.el-footer {
  text-align: center;
  padding: 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e9ecef 100%);
  color: var(--text-secondary);
  border-top: 1px solid var(--border-color);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .header-container {
    padding: 0 15px;
  }
  
  .logo {
    font-size: 18px;
  }
  
  nav {
    gap: 4px;
  }
  
  .nav-link {
    padding: 8px 12px;
    font-size: 13px;
  }
  
  .nav-link span {
    display: none;
  }
  
  .user-info-display span.username {
    display: none;
  }
  
  .logout-btn span {
    display: none;
  }
  
  .el-main {
    padding: 20px 15px;
  }
}
</style>