<template>
  <div class="home">
    <el-row :gutter="20">
      <el-col :span="16">
        <el-card shadow="hover" class="welcome-card">
          <template #header>
            <div class="card-header">
              <span>欢迎来到个人博客系统</span>
            </div>
          </template>
          <div class="welcome-content">
            <h2>发现精彩内容</h2>
            <p>这是一个基于Python+Vue3开发的现代博客系统，支持文章发布、评论互动和管理员后台管理。</p>
            <el-button type="primary" @click="toArticleList">浏览文章</el-button>
            <template v-if="!userStore.isLoggedIn">
              <el-button @click="toRegister" style="margin-left: 10px;">立即注册</el-button>
            </template>
          </div>
        </el-card>
        
        <div class="latest-articles">
          <h3>最新文章</h3>
          <el-card v-for="article in latestArticles" :key="article.id" shadow="hover" class="article-card">
            <router-link :to="'/article/' + article.id" class="article-link">
              <h4>{{ article.title }}</h4>
              <div class="article-meta">
                <span>作者：{{ getAuthorName(article.author_id) }}</span>
                <span>分类：{{ article.category || '未分类' }}</span>
                <span>{{ formatDate(article.created_at) }}</span>
              </div>
              <p class="article-excerpt">{{ getExcerpt(article.content) }}</p>
              <div class="article-tags">
                <el-tag v-for="tag in article.tags" :key="tag" size="small">{{ tag }}</el-tag>
              </div>
            </router-link>
          </el-card>
        </div>
      </el-col>
      
      <el-col :span="8">
        <el-card shadow="hover" class="sidebar-card">
          <template #header>
            <div class="card-header">
              <span>快速链接</span>
            </div>
          </template>
          <div class="quick-links">
            <router-link to="/articles" class="link-item">
              <el-icon><Document /></el-icon>
              <span>所有文章</span>
            </router-link>
            <template v-if="userStore.isLoggedIn">
              <router-link to="/article/create" class="link-item">
                <el-icon><Edit /></el-icon>
                <span>写文章</span>
              </router-link>
              <template v-if="userStore.user?.role === 'admin'">
                <router-link to="/admin" class="link-item">
                  <el-icon><Setting /></el-icon>
                  <span>管理后台</span>
                </router-link>
              </template>
            </template>
          </div>
        </el-card>
        
        <el-card shadow="hover" class="sidebar-card">
          <template #header>
            <div class="card-header">
              <span>热门分类</span>
            </div>
          </template>
          <div class="categories">
            <el-tag v-for="category in categories" :key="category" size="small" class="category-tag">
              {{ category }}
            </el-tag>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, getCurrentInstance } from 'vue'
import { useRouter } from 'vue-router'
import { Document, Edit, Setting } from '@element-plus/icons-vue'
import { userStore } from '../stores/user'

// 从app实例获取axios
const { proxy } = getCurrentInstance() as any
const axios = proxy.$axios

const router = useRouter()
const latestArticles = ref<any[]>([])
const categories = ref<string[]>(['技术', '前端', '后端', '数据科学', 'API设计', '工具'])
const authors = ref<Map<number, string>>(new Map())

const toArticleList = () => {
  router.push('/articles')
}

const toRegister = () => {
  router.push('/register')
}

const getExcerpt = (content: string) => {
  const text = content.replace(/[\n\r#*`\[\]]/g, ' ')
  return text.length > 150 ? text.substring(0, 150) + '...' : text
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

const getAuthorName = (authorId: number) => {
  return authors.value.get(authorId) || '未知作者'
}

const loadLatestArticles = async () => {
    try {
      console.log('开始请求文章列表...')
      const response = await axios.get('/api/articles?per_page=5')
      console.log('文章列表响应:', response.data)
      
      // 检查响应数据结构
      if (response.data && Array.isArray(response.data.articles)) {
        latestArticles.value = response.data.articles
        console.log('成功加载文章数量:', latestArticles.value.length)
        
        // 加载作者信息
        const authorIds = [...new Set(latestArticles.value.map(a => a.author_id))]
        console.log('需要加载的作者ID:', authorIds)
        
        for (const id of authorIds) {
          try {
            const userResponse = await axios.get(`/api/auth/users/${id}`)
            console.log(`作者${id}信息:`, userResponse.data)
            authors.value.set(id, userResponse.data.username)
          } catch (userError) {
            console.error(`加载作者${id}信息失败:`, userError)
            authors.value.set(id, '未知作者')
          }
        }
      } else {
        console.error('文章列表数据结构不符合预期:', response.data)
      }
    } catch (error: any) {
      console.error('加载文章失败:', error)
      console.error('错误详情:', error.response ? error.response.data : '无响应数据')
    }
  }

onMounted(() => {
  // 恢复用户状态
  userStore().restoreUser()
  loadLatestArticles()
})
</script>

<style scoped>
.home {
  padding-bottom: 40px;
}

.welcome-card {
  margin-bottom: 30px;
}

.welcome-content {
  padding: 20px 0;
}

.welcome-content h2 {
  margin-bottom: 10px;
  color: #333;
}

.welcome-content p {
  margin-bottom: 20px;
  color: #666;
  line-height: 1.6;
}

.latest-articles h3 {
  margin-bottom: 20px;
  color: #333;
  font-size: 20px;
}

.article-card {
  margin-bottom: 20px;
  transition: transform 0.3s;
}

.article-card:hover {
  transform: translateY(-5px);
}

.article-link {
  text-decoration: none;
  color: inherit;
  display: block;
}

.article-link h4 {
  margin-bottom: 10px;
  color: #333;
  font-size: 18px;
}

.article-meta {
  display: flex;
  gap: 15px;
  margin-bottom: 10px;
  font-size: 14px;
  color: #999;
}

.article-excerpt {
  margin-bottom: 10px;
  color: #666;
  line-height: 1.6;
}

.article-tags {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

.sidebar-card {
  margin-bottom: 20px;
}

.quick-links {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.link-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border-radius: 4px;
  text-decoration: none;
  color: #333;
  transition: background-color 0.3s;
}

.link-item:hover {
  background-color: #f5f7fa;
  color: #1890ff;
}

.categories {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.category-tag {
  cursor: pointer;
}
</style>