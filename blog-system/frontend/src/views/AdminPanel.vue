<template>
  <div class="admin-panel">
    <el-card shadow="hover" class="panel-card">
      <template #header>
        <div class="card-header">
          <h2>管理员面板</h2>
        </div>
      </template>
      
      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane label="统计信息" name="stats">
          <div class="stats-container">
            <el-row :gutter="20">
              <el-col :xs="24" :sm="12" :md="8">
                <el-card shadow="hover" class="stat-card">
                  <template #header>
                    <div class="stat-header">
                      <span>用户总数</span>
                    </div>
                  </template>
                  <div class="stat-value">{{ stats.totalUsers || 0 }}</div>
                </el-card>
              </el-col>
              <el-col :xs="24" :sm="12" :md="8">
                <el-card shadow="hover" class="stat-card">
                  <template #header>
                    <div class="stat-header">
                      <span>文章总数</span>
                    </div>
                  </template>
                  <div class="stat-value">{{ stats.totalArticles || 0 }}</div>
                </el-card>
              </el-col>
              <el-col :xs="24" :sm="12" :md="8">
                <el-card shadow="hover" class="stat-card">
                  <template #header>
                    <div class="stat-header">
                      <span>评论总数</span>
                    </div>
                  </template>
                  <div class="stat-value">{{ stats.totalComments || 0 }}</div>
                </el-card>
              </el-col>
            </el-row>
            
            <el-card shadow="hover" class="recent-activity-card">
              <template #header>
                <div class="card-header">
                  <span>最近活动</span>
                </div>
              </template>
              <div class="activity-list">
                <div v-if="loadingStats" class="loading">
                  <el-skeleton :rows="5" animated />
                </div>
                <template v-else>
                  <div v-if="stats.recentActivities && stats.recentActivities.length > 0">
                    <div v-for="(activity, index) in stats.recentActivities" :key="index" class="activity-item">
                      <div class="activity-time">{{ formatDate(activity.timestamp) }}</div>
                      <div class="activity-content">{{ activity.content }}</div>
                    </div>
                  </div>
                  <div v-else class="no-activities">
                    <el-empty description="暂无活动记录"></el-empty>
                  </div>
                </template>
              </div>
            </el-card>
          </div>
        </el-tab-pane>
        
        <el-tab-pane label="用户管理" name="users">
          <div class="users-container">
            <el-input
              v-model="userSearchQuery"
              placeholder="搜索用户"
              prefix-icon="el-icon-search"
              clearable
              style="margin-bottom: 20px;" 
              @input="handleUserSearch"
            />
            
            <el-table
              v-loading="loadingUsers"
              :data="usersData"
              style="width: 100%;"
              stripe
            >
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="username" label="用户名" width="180" />
              <el-table-column prop="email" label="邮箱" width="250" />
              <el-table-column prop="role" label="角色" width="120">
                <template #default="{ row }">
                  <el-tag :type="row.role === 'admin' ? 'danger' : 'success'" size="small">
                    {{ row.role === 'admin' ? '管理员' : '普通用户' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="created_at" label="注册时间" width="180">
                <template #default="{ row }">
                  {{ formatDate(row.created_at) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="280" fixed="right">
                <template #default="{ row }">
                  <el-button 
                    type="primary" 
                    size="small" 
                    @click="editUser(row)"
                    :disabled="row.id === currentUserId"
                  >
                    编辑信息
                  </el-button>
                  <el-button 
                    type="warning" 
                    size="small" 
                    @click="editUserRole(row)"
                    :disabled="row.id === currentUserId"
                  >
                    编辑角色
                  </el-button>
                  <el-button 
                    type="danger" 
                    size="small" 
                    @click="deleteUser(row.id)"
                    :disabled="row.id === currentUserId"
                  >
                    删除
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
            
            <div class="pagination" v-if="!loadingUsers">
              <el-pagination
                v-model:current-page="usersCurrentPage"
                v-model:page-size="usersPageSize"
                :page-sizes="[10, 20, 50]"
                :total="usersTotal"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleUsersSizeChange"
                @current-change="handleUsersCurrentChange"
              />
            </div>
          </div>
        </el-tab-pane>
        
        <el-tab-pane label="文章管理" name="articles">
          <div class="articles-container">
            <el-input
              v-model="articleSearchQuery"
              placeholder="搜索文章"
              prefix-icon="el-icon-search"
              clearable
              style="margin-bottom: 20px;" 
              @input="handleArticleSearch"
            />
            
            <el-table
              v-loading="loadingArticles"
              :data="articlesData"
              style="width: 100%;"
              stripe
            >
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="title" label="标题">
                <template #default="{ row }">
                  <router-link :to="'/article/' + row.id" class="article-title-link">
                    {{ row.title }}
                  </router-link>
                </template>
              </el-table-column>
              <el-table-column prop="author_id" label="作者" width="150">
                <template #default="{ row }">
                  {{ getAuthorName(row.author_id) }}
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="120">
                <template #default="{ row }">
                  <el-tag :type="row.status === 'published' ? 'success' : 'info'" size="small">
                    {{ row.status === 'published' ? '已发布' : '草稿' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="created_at" label="创建时间" width="180">
                <template #default="{ row }">
                  {{ formatDate(row.created_at) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="120" fixed="right">
                <template #default="{ row }">
                  <el-button 
                    type="danger" 
                    size="small" 
                    @click="deleteArticle(row.id)"
                  >
                    删除
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
            
            <div class="pagination" v-if="!loadingArticles">
              <el-pagination
                v-model:current-page="articlesCurrentPage"
                v-model:page-size="articlesPageSize"
                :page-sizes="[10, 20, 50]"
                :total="articlesTotal"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleArticlesSizeChange"
                @current-change="handleArticlesCurrentChange"
              />
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, getCurrentInstance } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { userStore } from '../stores/user'

// 从app实例获取axios
const { proxy } = getCurrentInstance() as any
const axios = proxy.$axios

const router = useRouter()
const store = userStore()

const activeTab = ref('stats')
const currentUserId = computed(() => store.user?.id)

// 监听标签切换事件
const handleTabChange = (tab: string) => {
  if (tab === 'users') {
    loadUsers()
  } else if (tab === 'articles') {
    loadArticles()
  } else if (tab === 'stats') {
    loadStats()
  }
}

// 统计信息
const stats = reactive({
  totalUsers: 0,
  totalArticles: 0,
  totalComments: 0,
  recentActivities: [] as any[]
})
const loadingStats = ref(false)

// 用户管理
const usersData = ref<any[]>([])
const loadingUsers = ref(false)
const usersCurrentPage = ref(1)
const usersPageSize = ref(10)
const usersTotal = ref(0)
const userSearchQuery = ref('')

// 文章管理
const articlesData = ref<any[]>([])
const loadingArticles = ref(false)
const articlesCurrentPage = ref(1)
const articlesPageSize = ref(10)
const articlesTotal = ref(0)
const articleSearchQuery = ref('')
const authors = ref<Map<number, string>>(new Map())

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getAuthorName = (authorId: number) => {
  return authors.value.get(authorId) || `用户${authorId}`
}

// 加载统计信息
const loadStats = async () => {
  loadingStats.value = true
  try {
    const response = await axios.get('/api/admin/statistics')
    stats.totalUsers = response.data.total_users
    stats.totalArticles = response.data.total_articles
    stats.totalComments = response.data.total_comments
    stats.recentActivities = [] // 后端没有提供最近活动数据
  } catch (error) {
    console.error('加载统计信息失败:', error)
    ElMessage.error('加载统计信息失败')
  } finally {
    loadingStats.value = false
  }
}

// 加载用户列表
const loadUsers = async () => {
  loadingUsers.value = true
  try {
    const response = await axios.get('/api/admin/users', {
      params: {
        page: usersCurrentPage.value,
        per_page: usersPageSize.value,
        search: userSearchQuery.value
      }
    })
    usersData.value = response.data.users
    usersTotal.value = response.data.total
  } catch (error) {
    console.error('加载用户列表失败:', error)
    ElMessage.error('加载用户列表失败')
  } finally {
    loadingUsers.value = false
  }
}

// 加载文章列表
const loadArticles = async () => {
  loadingArticles.value = true
  try {
    const response = await axios.get('/api/admin/articles/all')
    articlesData.value = response.data.articles
    articlesTotal.value = response.data.articles.length
    
    // 加载作者信息
    const authorIds = [...new Set(articlesData.value.map(a => a.author_id))]
    for (const id of authorIds) {
      if (!authors.value.has(id)) {
        try {
          // 从已加载的用户列表中查找作者信息，避免额外请求
          const user = usersData.value.find(u => u.id === id)
          if (user) {
            authors.value.set(id, user.username)
          } else {
            authors.value.set(id, `用户${id}`)
          }
        } catch {
          authors.value.set(id, `用户${id}`)
        }
      }
    }
  } catch (error) {
    console.error('加载文章列表失败:', error)
    ElMessage.error('加载文章列表失败')
  } finally {
    loadingArticles.value = false
  }
}

// 编辑用户信息
const editUser = (user: any) => {
  // 使用Vue Router编程式导航跳转到编辑用户页面
  router.push(`/admin/users/edit/${user.id}`)
}

// 编辑用户角色
const editUserRole = (user: any) => {
  const newRole = user.role === 'admin' ? 'user' : 'admin'
  
  // 使用Vue Router跳转到确认页面
  router.push({
    name: 'ConfirmAction',
    params: { actionType: 'edit-role' },
    query: { 
      userId: user.id, 
      username: user.username, 
      currentRole: user.role, 
      newRole: newRole 
    }
  })
}

// 删除用户
const deleteUser = (userId: number) => {
  // 查找用户信息
  const user = usersData.value.find(u => u.id === userId)
  if (!user) return
  
  // 使用Vue Router跳转到确认页面
  router.push({
    name: 'ConfirmAction',
    params: { actionType: 'delete-user' },
    query: { userId: userId, username: user.username }
  })
}

// 删除文章
const deleteArticle = (articleId: number) => {
  // 查找文章信息
  const article = articlesData.value.find(a => a.id === articleId)
  if (!article) return
  
  // 使用Vue Router跳转到确认页面
  router.push({
    name: 'ConfirmAction',
    params: { actionType: 'delete-article' },
    query: { articleId: articleId, title: article.title }
  })
}

// 用户搜索
const handleUserSearch = () => {
  usersCurrentPage.value = 1
  loadUsers()
}

// 文章搜索
const handleArticleSearch = () => {
  articlesCurrentPage.value = 1
  loadArticles()
}

// 用户分页
const handleUsersSizeChange = (newSize: number) => {
  usersPageSize.value = newSize
  usersCurrentPage.value = 1
  loadUsers()
}

const handleUsersCurrentChange = (newCurrent: number) => {
  usersCurrentPage.value = newCurrent
  loadUsers()
}

// 文章分页
const handleArticlesSizeChange = (newSize: number) => {
  articlesPageSize.value = newSize
  articlesCurrentPage.value = 1
  loadArticles()
}

const handleArticlesCurrentChange = (newCurrent: number) => {
  articlesCurrentPage.value = newCurrent
  loadArticles()
}

// 加载初始数据
onMounted(() => {
  // 严格验证用户是否为管理员
  if (!store.isLoggedIn) {
    ElMessage.error('请先登录')
    router.push({ path: '/login', query: { redirect: '/admin' } })
    return
  }
  
  if (store.user?.role !== 'admin') {
    ElMessage.error('您没有权限访问管理员面板')
    router.push('/')
    return
  }
  
  // 加载统计信息
  loadStats()
})
</script>

<style scoped>
.admin-panel {
  padding-bottom: 40px;
}

.panel-card {
  border-radius: 8px;
}

.card-header h2 {
  margin: 0;
  color: #333;
}

/* 统计信息 */
.stats-container {
  padding: 20px 0;
}

.stat-card {
  text-align: center;
  transition: transform 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
}

.stat-header {
  display: flex;
  justify-content: center;
}

.stat-value {
  font-size: 36px;
  font-weight: bold;
  color: #409eff;
  text-align: center;
  padding: 20px 0;
}

.recent-activity-card {
  margin-top: 20px;
}

.activity-item {
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-time {
  font-size: 12px;
  color: #999;
  margin-bottom: 5px;
}

.activity-content {
  font-size: 14px;
  color: #666;
}

.loading {
  margin-bottom: 20px;
}

.no-activities {
  padding: 40px 0;
  text-align: center;
}

/* 用户和文章管理 */
.users-container,
.articles-container {
  padding: 20px 0;
}

.article-title-link {
  color: #333;
  text-decoration: none;
}

.article-title-link:hover {
  color: #409eff;
}

.pagination {
  margin-top: 20px;
  text-align: right;
}
</style>