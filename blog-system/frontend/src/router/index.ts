import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import { userStore } from '../stores/user'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/Home.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false },
    beforeEnter: (to, from, next) => {
      const store = userStore()
      if (store.isLoggedIn) {
        next({ name: 'Home' })
      } else {
        next()
      }
    }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/Register.vue'),
    meta: { requiresAuth: false },
    beforeEnter: (to, from, next) => {
      const store = userStore()
      if (store.isLoggedIn) {
        next({ name: 'Home' })
      } else {
        next()
      }
    }
  },
  {
    path: '/articles',
    name: 'ArticleList',
    component: () => import('../views/ArticleList.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/article/:id',
    name: 'ArticleDetail',
    component: () => import('../views/ArticleDetail.vue'),
    meta: { requiresAuth: false },
    props: true
  },
  {
    path: '/article/create',
    name: 'ArticleCreate',
    component: () => import('../views/ArticleEdit.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/article/edit/:id',
    name: 'ArticleEdit',
    component: () => import('../views/ArticleEdit.vue'),
    meta: { requiresAuth: true },
    props: true
  },
  {
      path: '/admin',
      name: 'admin',
      component: () => import('../views/AdminPanel.vue'),
      meta: { requiresAuth: true, requiresAdmin: true }
    },
  {
    path: '/confirm/:actionType',
    name: 'ConfirmAction',
    component: () => import('../views/ConfirmAction.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/users/edit/:userId',
    name: 'EditUser',
    component: () => import('../views/EditUser.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/profile',
    name: 'UserProfile',
    component: () => import('../views/UserProfile.vue'),
    meta: { requiresAuth: true }
  },
  // 404页面
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('../views/NotFound.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 全局路由守卫
router.beforeEach((to, from, next) => {
  const store = userStore()
  
  // 添加调试日志
  console.log('===== 路由守卫调试信息 =====')
  console.log('当前路径:', to.path)
  console.log('需要登录:', to.meta.requiresAuth)
  console.log('需要管理员权限:', to.meta.requiresAdmin)
  console.log('用户是否登录:', store.isLoggedIn)
  console.log('用户角色:', store.user?.role)
  console.log('==========================')
  
  // 检查是否需要登录
  if (to.meta.requiresAuth && !store.isLoggedIn) {
    console.log('路由守卫: 需要登录，跳转到登录页')
    next({ name: 'Login', query: { redirect: to.fullPath } })
    return
  }
  
  // 检查是否需要管理员权限
  if (to.meta.requiresAdmin) {
    console.log('路由守卫: 需要管理员权限，检查用户角色')
    if (store.user?.role !== 'admin') {
      console.log('路由守卫: 非管理员用户，跳转到首页')
      // 导入ElMessage用于错误提示
      import('element-plus').then(({ ElMessage }) => {
        ElMessage.error('您没有权限访问管理员页面')
      })
      next({ name: 'Home' })
      return
    }
  }
  
  console.log('路由守卫: 权限检查通过，允许访问')
  next()
})

export default router